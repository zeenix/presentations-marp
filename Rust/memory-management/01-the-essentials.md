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
Part 1: The Essentials

---
Zeeshan Ali Khan

---
Mercedes-Benz Vans

---
Digital Upfitter Platform

---
![bg fit](esprinter.jpg)

---
A bit of a recap

---
What is Rust? 🦀

---
Systems Programming

---
Safe + Efficient

---
Unique Memory Management

---
Manual Memory Management

---
<style scoped> section{ text-align: left; }</style>

```c
void do_something() {
    int *p = malloc(sizeof(int));
    *p = 5;
    // ...
    free(p);
}
```

---
Garbage Collection

---
<style scoped> section{ text-align: left; }</style>

```go
fn something() {
    var p *int = new(int)
    *p = 5
    // p will be freed by the GC *eventually* after last usage
}
```

---
Ownership model + scopes

---
<style scoped> section{ text-align: left; }</style>

```rust
fn do_something() {
    let s = String::from("hello world");
    // ...
}
// s is dropped here (100% guaranteed)
```

---
References & Borrowing

---
<style scoped> section{ text-align: left; }</style>

```rust
let s1 = String::from("hello");
let s2 = &s1;
println!("The length of '{}' is {}.", s1, s2.len());
```

---
<style scoped> section{ text-align: left; }</style>

```rust
fn add_first_two(v: &Vec<i32>) -> i32 {
    return v[0] + v[1];
}

let v = vec![1, 2, 3];
let answer = add_first_two(&v);

println!("{} + {} = {}", v[0], v[1], answer);
```

---
Non-mutable state by default

---
<style scoped> section{ text-align: left; }</style>

```rust
let mut x = 5;
x = 6;
```

---
Mutable Borrows

---
<style scoped> section{ text-align: left; }</style>

```rust
let mut x = 5;
let y = &mut x;
*y += 1;
```

---
Smart pointers

---
`Rc<T>` and `Arc<T>`

---
🎉 No null pointers 🎉

---
<style scoped> section{ text-align: left; }</style>

```rust
enum Option<T> {
    None,
    Some(T),
}
```

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
FFI

---
What makes up a smart pointer?

---
`Deref` and `Drop`

---
<style scoped> section{ text-align: left; }</style>

```rust
trait Deref {
    // Associated type
    type Target: ?Sized;

    fn deref(&self) -> &Self::Target;
}
```

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
`Sized` vs `?Sized`

---
`Sized` a Marker Trait

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

```console
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
`dyn Trait`

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
Lifetime Annotations

---
Every reference has a lifetime

---
Purpose?

---
Prevent dangling references

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
Typically inferred

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

