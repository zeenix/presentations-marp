---
marp: true
style: |
  section {
      text-align: center;
      font-size: 40px;
  }
---
# Rust for beginners

<br/>
Part 4: A Deep Dive

---
`Box<T>`

---
<style scoped> section{ text-align: left; }</style>

```rust
let b = Box::new(5);
// `*` is a dereference, opposite of `&`.
let five: u8 = *b;
```

---
What's the usecase?

---
Recursive data structures

---
<style scoped> section{ text-align: left; }</style>

```rust
enum List {
    Cons(i32, Box<List>),
    Nil,
}
```

---
Dynamic dispatch

---
Example Later ⌚

---
More on Strings

---
2 types of strings?

---
![bg fit](rust-string-meme.jpg)

---
Focus on Important Ones

---
Remember `&str`?

---
What's `str`?

---
`Sized` vs `?Sized`

---
`Sized`: a Marker Trait

---
`Sized`: known size at compile time

---
`?Sized`: may not have a known size at compile time

---
IOW may not implement `Sized`

---
Most types are `Sized`

---
There are exceptions

---
`str`

---
<style scoped> section{ text-align: left; }</style>

```rust
let s: str = "How's it going?";
```

---
<style scoped> section{ text-align: left; }</style>

```rust
6 | let s: str = "How's it going?";
  |     ^ doesn't have a size known at compile-time
  |
  = help: the trait `Sized` is not implemented for `str`
  = note: all local variables must have a statically known size
  = help: unsized locals are gated as an unstable feature
help: consider borrowing here
  |
6 | let s: &str = "How's it going?";
  |        +
```

---
Only References or dynamically-sized types

---
<style scoped> section{ text-align: left; }</style>

```rust
// This works.
let s1: &str = "How's it going?";
let s2 = String::from("How's it going?");
let s2: &str = &s2;
```

---
Why call it a string slice?

---
<style scoped> section{ text-align: left; }</style>

```rust
// parens only here for clarity.
let s1: &str = &("How's it going?"[0..2]);
let s2 = String::from("How's it going?");
let s2: &str = &s2[2..5];
```

---
Slices

---
`[T]`

---
dynamically-sized view into a contiguous sequence

---
Array and `Vec`

---
<style scoped> section{ text-align: left; }</style>

```rust
let array = [3, 1, 5];
let slice = &array[0..1];

let vec = vec![3, 1, 5];
let slice = &vec[0..1];
```

---
Another Unsized Type

---
`dyn Trait`

---
Remember Dynamic Dispatch?

---
<style scoped> section{ text-align: left; }</style>

```rust
trait Animal {
    fn make_sound(&self);
}
struct Dog;
impl Animal for Dog {
    fn make_sound(&self) {
        println!("Woof!");
    }
}
struct Cat;
impl Animal for Cat {
    fn make_sound(&self) {
        println!("Meow!");
    }
}

let animals: Vec<Box<dyn Animal>> = vec![
    Box::new(Dog),
    Box::new(Cat),
];

for animal in animals {
    animal.make_sound();
}
```

---
`Sized` constraint implied by default

---
<style scoped> section{ text-align: left; }</style>

```rust
trait Deref {
    // Same as: type Target: Sized;
    type Target;

    // Return type is `&str` for `Target = str`
    fn deref(&self) -> &Self::Target;
}
```

---
`Sized` constraint not needed

---
<style scoped> section{ text-align: left; }</style>

```rust
// The actual definition in the standard library.
trait Deref {
    // Can now be used with `str`.
    type Target: ?Sized;

    fn deref(&self) -> &Self::Target;
}
```

---
Talking of `Deref`

---
What makes up a smart pointer?

---
Wrapper Types

---
`Deref` and `Drop`

---
<style scoped> section{ text-align: left; }</style>

```rust
use std::ops::Deref;

struct MyBox<T>(T);

impl<T> Deref for MyBox<T> {
    type Target = T;

    fn deref(&self) -> &T {
        &self.0
    }
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
struct MyBox<T>(T);

impl<T> Drop for MyBox<T> {
    fn drop(&mut self) {
        // In real code, you'd free resources here,
        // e.g flush and closing files/sockets.
        println!("Dropping MyBox!");
    }
}
```

---
Associated types

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
More on lifetimes

---
<style scoped> section{ text-align: left; }</style>

```rust
    let r;

    {
        let x = 5;
        r = &x;
    }

    println!("r: {}", r);
```

---
<style scoped> section{ text-align: left; }</style>

```console
error[E0597]: `x` does not live long enough
  --> src/lib.rs:397:13
   |
9  |         r = &x;
   |             ^^ borrowed value does not live long enough
10 |     }
   |     - `x` dropped here while still borrowed
11 |
12 |     println!("r: {}", r);
   |                       - borrow later used here
```

---
The Borrow Checker

---
<style scoped> section{ text-align: left; }</style>

```rust
&i32        // a reference
&'a i32     // a reference with an explicit lifetime
&'a mut i32 // a mutable reference with an explicit lifetime
```

---
<style scoped> section{ text-align: left; }</style>

```rust
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```

---
Thinking in lifetimes

---
<style scoped> section{ text-align: left; }</style>

```rust
fn longest<'a>(x: &str, y: &str) -> &'a str {
    let result = String::from("really long string");
    result.as_str()
}
```

---
Lifetimes in Structs

---
<style scoped> section{ text-align: left; }</style>

```rust
// Can not outlive the string reference
struct ImportantExcerpt<'a> {
    part: &'a str,
}

impl<'a> ImportantExcerpt<'a> {
    // Same as: fn new(part: &'a str) -> Self {
    fn new(part: &'a str) -> ImportantExcerpt<'a> {
        ImportantExcerpt { part }
    }
}
```

---
Lifetime Elision

---
3 rules

---
<style scoped> section{ font-size: 30px; }</style>

1\. Each parameter that is a reference gets its own lifetime parameter.

---
<style scoped> section{ text-align: left; }</style>

```rust
fn func1(x: &str, y: &str) {
}

fn func2<'a, 'b>(x: &'a str, y: &'b str) {
}
```

---
<style scoped> section{ font-size: 30px; }</style>

2\. If there is exactly one input lifetime parameter, that lifetime is assigned to all output lifetime parameters.

---
<style scoped> section{ text-align: left; }</style>

```rust
fn func1(x: &str) -> (&str, &str) {
    (x, x)
}

fn func2<'a>(x: &'a str) -> (&'a str, &'a str) {
    (x, x)
}
```

---
<style scoped> section{ font-size: 30px; }</style>

3\. If there are multiple input lifetime parameters, but one of them is `&self` or `&mut self`, the lifetime of `self` is assigned to all output lifetime parameters.

---
<style scoped> section{ text-align: left; }</style>

```rust
struct ImportantExcerpt<'a> {
    part: &'a str,
}

impl<'a> ImportantExcerpt<'a> {
    //Same as: fn part<'b, 'c>(&'b self, nothing: &'c str) -> &'b str {
    fn part(&self, nothing: &str) -> &str {
        self.part
    }
}
```

---
Lifetime constraints

---
<style scoped> section{ text-align: left; }</style>

```rust
struct ImportantExcerpt<'a> {
    part: &'a str,
}

impl<'a> ImportantExcerpt<'a> {
    // Won't work: fn part<'b, 'c>(&'b self, nothing: &'c str) -> &'b str {
    fn part<'b, 'c: 'b>(&'b self, nothing: &'c str) -> (&str, &str) {
        (self.part, nothing)
    }
}
```

---
# ☕

---
Fearless Concurrency

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
`Send` + `Sync`

---
Implemented for owned types

---
Can be implemented for reference types

---
An Escape Hatch to the Unsafe World

---
`unsafe` keyword

---
<style scoped> section{ text-align: left; }</style>

```rust
unsafe {
   // unsafe code here
}

unsafe fn dangerous() {}
```

---
Not necessarily unsafe

---
Compiler can't verify

---
"I know what I'm doing"

---
Use cases

---
<style scoped> section{ text-align: left; }</style>

* Hardware interfacing
* FFI

---
What does it give you?

---
<style scoped> section{ text-align: left; }</style>

* Dereference raw pointers
* Call unsafe functions
* Implement unsafe traits
* Access or modify a mutable static variable
* Access fields of unions

---
Dereference raw pointers

---
What's a raw pointer?

---
Similar to references

---
Closer to C pointers

---
Two types

---
<style scoped> section{ text-align: left; }</style>

* `*const T`
* `*mut T`

---
Note: `*` not a dereference operator

---
<style scoped> section{ text-align: left; }</style>

* Allowed to ignore the borrowing rules
* Not guaranteed to point to valid memory
* Allowed to be null
* No automatic cleanup

---
<style scoped> section{ text-align: left; }</style>

```rust
let mut num = 5;

// Notice the lack of `unsafe`.
let r1 = &num as *const i32;
let r2 = &mut num as *mut i32;
```

---
Can assign any arbitrary address

---
<style scoped> section{ text-align: left; }</style>

```rust
let address: usize = 0x012345;
let r = address as *const i32;
```

---
Can't dereference in safe code

---
<style scoped> section{ text-align: left; }</style>

```rust
let mut num = 5;

// Notice the lack of `unsafe`.
let r1 = &num as *const i32;
let r2 = &mut num as *mut i32;

unsafe {
   println!("r1 is: {}", *r1);
   println!("r2 is: {}", *r2);
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
let address: usize = 0x012345;
let r = address as *const i32;
unsafe {
   // Will most definitely crash. 💣
   println!("r is: {}", *r);
}
```

---
Calling unsafe functions

---
<style scoped> section{ text-align: left; }</style>

```rust
unsafe fn dangerous() {}

unsafe {
   dangerous();
}
```

---
Why not always use `unsafe` block?

---
Block typically the right approach

---
Safe Abstractions

---
`<[T]>::split_at_mut`

---
<style scoped> section{ text-align: left; }</style>

```rust
let mut v = vec![1, 2, 3, 4, 5, 6];
let r = &mut v;

let (a, b) = r.split_at_mut(3);

assert_eq!(a, &mut [1, 2, 3]);
assert_eq!(b, &mut [4, 5, 6]);
```

---
Let's implement it ourselves

---
<style scoped> section{ text-align: left; }</style>

```rust
fn split_at_mut(
    values: &mut [i32],
    mid: usize,
) -> (&mut [i32], &mut [i32]) {
    let len = values.len();
    assert!(mid <= len);

    (&mut values[..mid], &mut values[mid..])
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
error[E0499]: cannot borrow `*values` as mutable more than once at a time
  --> src/lib.rs:207:31
   |
6  |     values: &mut [i32],
   |             - let's call the lifetime of this reference `'1`
...
13 |     (&mut values[..mid], &mut values[mid..])
   |     --------------------------^^^^^^--------
   |     |     |                   |
   |     |     |                   second mutable borrow occurs here
   |     |     first mutable borrow occurs here
   |     returning this value requires that `*values` is borrowed for `'1`
```

---
<style scoped> section{ text-align: left; }</style>

```rust
use std::slice::from_raw_parts_mut;

fn split_at_mut(
    values: &mut [i32],
    mid: usize,
) -> (&mut [i32], &mut [i32]) {
    let len = values.len();
    assert!(mid <= len);

    let ptr = values.as_mut_ptr();
    unsafe {
        (
            from_raw_parts_mut(ptr, mid),
            from_raw_parts_mut(ptr.add(mid), len - mid),
        )
    }
}
```

---
Wny is `from_raw_parts_mut` unsafe?

---
<style scoped> section{ text-align: left; }</style>

```rust
use std::slice::from_raw_parts_mut;

let address: usize = 0x01234;
let r = address as *mut i32;

let values: &mut [i32] = unsafe {
    from_raw_parts_mut(r, 10000)
};
```

---
FFI

---
`extern` keyword

---
<style scoped> section{ text-align: left; }</style>

```rust
extern "C" {
    // from libc
    fn abs(input: i32) -> i32;
}

unsafe {
    println!(
        "Absolute value of -3 according to C: {}",
        abs(-3),
    );
}
```

---
bindgen

---
The other way around?

---
<style scoped> section{ text-align: left; }</style>

```rust
#[no_mangle]
pub extern "C" fn call_from_c() {
    println!("Just called a Rust function from C!");
}
```

---
Notice no `unsafe` involved

---
<style scoped> section{ text-align: left; }</style>

```c
extern void call_from_c();

int main(void) {
    call_from_c();

    return 0;
}
```

---
<style scoped> section{ text-align: left; }</style>

```toml
name = "rust_from_c"

[lib]
crate-type = ["cdylib"]
```

---
<style scoped> section{ text-align: left; }</style>

```sh
$ cargo build
$ gcc call_rust.c -o call_rust -lrust_from_c -L./target/debug
$ LD_LIBRARY_PATH=./target/debug ./call_rust
```

---
cbindgen

---
<style scoped> section{ text-align: left; }</style>

```sh
$ cbindgen \
    --config cbindgen.toml \
    --crate my_rust_library 
    --output my_header.h
```

---
Unsafe Traits

---
Rembember `Send` & `Sync` traits?

---
Typically auto implemented

---
<style scoped> section{ text-align: left; }</style>

```rust
// `Rc` is neither `Send` nor `Sync`.
use std::rc::Rc;

struct Foo(Rc<u32>);

unsafe impl Send for Foo{}
unsafe impl Sync for Foo{}
```

---
Suggestions

---
<style scoped> section{ text-align: left; }</style>

* Keep it minimal
* Keep it fine grained
* Keep it isolated
* Provide safe abstractions
* Document invariants (`SAFETY:` comment)

---
# 🍻