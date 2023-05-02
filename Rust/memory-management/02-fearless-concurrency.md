---
marp: true
style: |
  section {
      text-align: center;
      font-size: 40px;
  }
---
# Rust Memory Management

<br/>
Part 2: Fearless Concurrency

---
Zeeshan Ali Khan

---
Mercedes-Benz Vans

---
Digital Upfitter Platform

---
![bg fit](esprinter.jpg)

---
Super quick recap

---
Unique Memory Management

---
Ownership model + scopes

---
References & Borrowing

---
Non-mutable state by default

---
Mutable Borrows

---
Smart pointers

---
`Rc<T>`, `Arc<T>` & `Box<T>`

---
`Deref` and `Drop`

---
**Note:** Often implied

---
<style scoped> section{ text-align: left; }</style>

```rust
// Example of implied `Deref`  with Box
let x = Box::new(-5);

assert_eq!(x.abs(), 5);
```

---
Lifetime Annotations

---
Typically inferred

---
Associated types

---
Another attempt at explaining 😼

---
<style scoped> section{ text-align: left; }</style>

```rust
trait Iterator {
    type Item;

    fn next(&mut self) -> Option<Self::Item>;
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
struct Counter {
    count: u32,
}

impl Iterator for Counter {
    type Item = u32;

    fn next(&mut self) -> Option<Self::Item> {
        self.count += 1;

        if self.count == 6 {
            None
        } else {
            Some(self.count)
        }
    }
}
```

---
Only 1 implementation per type

---
With generics: multiple impls possible

---
<style scoped> section{ text-align: left; }</style>

```rust
trait GenericIterator<Item> {
    fn next_generic(&mut self) -> Option<Item>;
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
impl GenericIterator<u32> for Counter {
    fn next_generic(&mut self) -> Option<u32> {
        self.next()
    }
}

impl GenericIterator<String> for Counter {
    fn next_generic(&mut self) -> Option<String> {
        self.next().map(|i| i.to_string())
    }
}
```

---
So what's the problem?

---
<style scoped> section{ text-align: left; }</style>

```rust
   let mut counter = Counter { count: 0 };

    // Type annotation **not** required 
    let next = counter.next().unwrap();
    println!("next: {}", next);

    // Type annotation required
    let next: u32 = counter.next_generic().unwrap();
    println!("next: {}", next);
```

---
Back to the topic

---
What's "fearless" about it?

---
Related to Memory Management?

---
Ownership model + Type system

---
Other languages

---
C/C++ 😱

---
Erlang

---
In Rust

---
Shared state w/o fear

---
Better performance than C 😎

---
Spawning Threads

---
<style scoped> section{ text-align: left; }</style>

```rust
use std::thread::{sleep, spawn};
use std::time::Duration;

// Takes a closure as an argument.
spawn(|| {
    for i in 1..10 {
        println!("hi number {} from the spawned thread!", i);
        sleep(Duration::from_millis(1));
    }
});

for i in 1..5 {
    println!("hi number {} from the main thread!", i);
    thread::sleep(Duration::from_millis(1));
}
```

---
Joining Threads

---
<style scoped> section{ text-align: left; }</style>

```rust
use std::thread::{sleep, spawn};
use std::time::Duration;

let handle = spawn(|| {
    sleep(Duration::from_millis(1));
});

join_handle.join().unwrap();
```

---
Sharing data between threads

---
<style scoped> section{ text-align: left; }</style>

```rust
use std::thread;

let v = vec![1, 2, 3];

let handle = thread::spawn(|| {
    println!("Here's a vector: {:?}", v);
});

handle.join().unwrap();
```

---
<style scoped> section{ text-align: left; }</style>

```rust
error[E0373]: closure may outlive the current function, but it borrows `v`,
which is owned by the current function
 --> src/main.rs:6:32
  |
6 |     let handle = thread::spawn(|| {
  |                                ^^ may outlive borrowed value `v`
7 |         println!("Here's a vector: {:?}", v);
  |                                           - `v` is borrowed here
  |
```

---
Try not sharing at all?

---
`move` Closures

---
<style scoped> section{ text-align: left; }</style>

```rust
use std::thread;

let v = vec![1, 2, 3];

let handle = thread::spawn(move || {
    println!("Here's a vector: {:?}", v);
});

handle.join().unwrap();
```

---
Channels

---
MPSC implementation in std

---
<style scoped> section{ text-align: left; }</style>

```rust
use std::sync::mpsc;
use std::thread;

let (tx, rx) = mpsc::channel();

let tx2 = tx.clone();
thread::spawn(move || {
    let val = String::from("hi");
    tx.send(val).unwrap();
});
thread::spawn(move || {
    let val = String::from("bye");
    tx2.send(val).unwrap();
});

for _ in 0..2 {
    let received = rx.recv().unwrap();
    println!("Got: {}", received);
}
```

---
Other types of channels

---
But I really need to share data between threads!

---
`Mutex<T>`

---
<style scoped> section{ text-align: left; }</style>

```rust
let counter = std::sync::Mutex::new(0);
let mut handles = vec![];

for _ in 0..10 {
    let handle = std::thread::spawn(move || {
        {
            // type: MutexGuard<i32>
            let mut num = counter.lock().unwrap();

            *num += 1;
        } // lock guard is dropped here.

        // Do things here that doesn't require the lock.
    });
    handles.push(handle);
}

for handle in handles {
    handle.join().unwrap();
}

println!("Result: {}", *counter.lock().unwrap());
```

---
Won't work!

---
<style scoped> section{ text-align: left; }</style>

```rust
error[E0382]: use of moved value: `counter`
  --> src/main.rs:9:36
   |
5  | let counter = Mutex::new(0);
   |     ------- move occurs because `counter` has type `Mutex<i32>`,
   |             which does not implement the `Copy` trait
...
9  | let handle = thread::spawn(move || {
   |                            ^^^^^^^ value moved into closure here,
   |                                    in previous iteration of loop
10 | let mut num = counter.lock().unwrap();
   |               ------- use occurs due to use in closure
```

---
`Arc<T>` to rescue!

---
<style scoped> section{ text-align: left; }</style>

```rust
let counter = std::arc::Arc::new(std::sync::Mutex::new(0));
let mut handles = vec![];

for _ in 0..10 {
    let counter = counter.clone();
    let handle = std::thread::spawn(move || {
        {
            // type: MutexGuard<i32>
            let mut num = counter.lock().unwrap();

            *num += 1;
        } // lock guard is dropped here.

        // Do things here that doesn't require the lock.
    });
    handles.push(handle);
}

for handle in handles {
    handle.join().unwrap();
}

println!("Result: {}", *counter.lock().unwrap());
```

---
**Note**: Data inside the lock

---
**Also note**: `counter` not mutable

---
How does it all work? 🤔

---
2 Marker Traits

---
`Send`

---
<style scoped> section{ text-align: left; }</style>

```rust
let counter = std::rc::Rc::new(std::sync::Mutex::new(0));
```

---
<style scoped> section{ text-align: left; }</style>

```rust
error[E0277]: `Rc<Mutex<i32>>` cannot be sent between threads safely
  --> src/main.rs:11:36
   |
11 |           let handle = thread::spawn(move || {
   |                        ------------- ^------
   |                        |             |
   |  ______________________|_____________within this `[closure@src/main.rs:11:36: 11:43]`
   | |                      |
   | |                      required by a bound introduced by this call
12 | |             let mut num = counter.lock().unwrap();
13 | |
14 | |             *num += 1;
15 | |         });
   | |_________^ `Rc<Mutex<i32>>` cannot be sent between threads safely
   |
   = help: within `[closure@src/main.rs:11:36: 11:43]`, the trait `Send` is not implemented for `Rc<Mutex<i32>>`
note: required because it's used within this closure
```

---
`Sync`

---
`RefCell<T>`

---
<style scoped> section{ text-align: left; }</style>

```rust
let counter = std::cell::RefCell::new(0);
let mut handles = vec![];

// Note: Not `move`d
let handle = std::thread::spawn(|| {
  let mut num = counter.borrow_mut();

  *num += 1;
});

handle.join().unwrap();

println!("Result: {}", counter.borrow());
```

---
<style scoped> section{ text-align: left; }</style>

```rust
error[E0277]: `RefCell<i32>` cannot be shared between threads safely
  --> src/main.rs:6:33
   |
6  |   let handle = std::thread::spawn(|| {
   |  ______________------------------_^
   | |              |
   | |              required by a bound introduced by this call
7  | |   let mut num = counter.borrow_mut();
8  | |
9  | |   *num += 1;
10 | | });
   | |_^ `RefCell<i32>` cannot be shared between threads safely
   |
   = help: the trait `Sync` is not implemented for `RefCell<i32>`
   = note: if you want to do aliasing and mutation between multiple threads, use `std::sync::RwLock` instead
   = note: required for `&RefCell<i32>` to implement `Send`
```

---

```rust
   required for `&RefCell<i32>` to implement `Send`
```

---
`Rc<T>` + `RefCell<T>`

---
`Arc<T>` + `Mutex<T>`

---
Scoped threads

---
Async/await?

---
Next time! :smile:

---
🙋🏻