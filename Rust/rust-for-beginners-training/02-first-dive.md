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
Part 2: Shallow First Dive

---

Where things get interesting

---
Non-mutable state by default

---
<style scoped> section{ text-align: left; }</style>

```rust
let x = 5;
// This should work, right?
x = 6;
```

---
<style scoped> section{ text-align: left; }</style>

```rust
error[E0384]: cannot assign twice to immutable variable `x`
 --> src/lib.rs:35:1
  |
5 | let x = 5;
  |     -
  |     |
  |     first assignment to `x`
  |     help: consider making this binding mutable: `mut x`
6 | x = 6;
  | ^^^^^ cannot assign twice to immutable variable
```

---
<style scoped> section{ text-align: left; }</style>

```rust
let mut x = 5;
// This works!
x = 6;
```

---
Ownership

---
<style scoped> section{ text-align: left; }</style>
Thinking in scopes

```rust
fn main() {
    let s1 = "hello";
    // s1 is valid from this point forward
    {
        let s2 = String::from("hello");
        // s2 is valid from this point forward
    }
    // inner scope is now over; s2 is no longer valid
}
// outer scope is now over; s1 is no longer valid
```

---
Strictly 1 Owner

---
<style scoped> section{ text-align: left; }</style>

```rust
let s1 = String::from("hello");
let s2 = s1;
println!("{}, world!", s1);
```

---
<style scoped> section{ text-align: left; }</style>

```rust
error[E0382]: borrow of moved value: `s1`
```

---
Same w/ Function Arguments

---
<style scoped> section{ text-align: left; }</style>

```rust
fn add_first_two(v: Vec<i32>) -> i32 {
    return v[0] + v[1];
}

let v = vec![1, 2, 3];
let answer = add_first_two(v);

println!("{} + {} = {}", v[0], v[1], answer);
```

---
Copy vs. Move

---
All basic types: Copy

---
Can't just move things around

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
Mutable Borrows

---
<style scoped> section{ text-align: left; }</style>

```rust
let mut x = 3;
let y = &mut x;
*y += 1;
```

---
Only 1 mutable borrow at a time

---
Think RwLock

---
But borrows are temporary

---
<style scoped> section{ text-align: left; }</style>

```rust
struct Heli {
    reg: String
}

impl Heli {
    fn new(reg: String) -> Heli {
        Heli { reg: reg}
    }

    // Other methods here
}

let reg = "G-HONI".to_string();
let heli = Heli::new(reg);

println!("Registration {}", reg);
```

---
<style scoped> section{ text-align: left; }</style>

```rust
16 |     let heli = Heli::new(reg);
   |                          --- value moved here
17 |
18 |     println!("Registration {}", reg);
   |                                 ^^^ value used
   |                                     after move
```

---
Smart pointers to the rescue!

---
`Rc<T>`

---
<style scoped> section{ text-align: left; }</style>

```rust
use std::rc::Rc;

struct Heli {
    reg: Rc<String>
}

impl Heli {
    fn new(reg: Rc<String>) -> Heli {
        Heli { reg: reg}
    }

    // Other methods here
}

let reg = Rc::new("G-HONI".to_string());
let heli = Heli::new(reg.clone());

println!("Registration {}", reg);
```

---
`Arc<T>`

---
Traits

---
<style scoped> section{ text-align: left; }</style>

```rust
trait Greet {
    fn say_hello(&self);
}

struct Person {
    name: String,
}

impl Greet for Person {
    fn say_hello(&self) {
        println!("Hello, my name is {}", self.name);
    }
}

let person = Person { name: String::from("Alice") };
person.say_hello();
```

---
Generics + Trait bounds

---
<style scoped> section{ text-align: left; }</style>

```rust
fn print_vec<T>(v: Vec<T>)
where
    T: std::fmt::Display,
{
    for item in v {
        println!("{}", item);
    }
}
```

---
`String` vs `&str`

---
`String`: Dynamically allocated & mutable

---
`&str`: string slice

---
<style scoped> section{ text-align: left; }</style>

```rust
// String literals
let s: &str = "Hello, world!";

// String allocated on the heap
let allocated = String::from("Hello, world!");
let s: &str = &allocated;

// Also valid
let s: &String = &allocated;
```

---
Lifetime Annotations

<br/>
The big scary 👾

---
Remember scopes?

---
Every reference has a lifetime

---
Purpose?

---
Prevent dangling references

---
Typically inferred

---
<style scoped> section{ text-align: left; }</style>

```rust
fn longest(s1: &str, s2: &str) -> &str {
    if s1.len() > s2.len() {
        s1
    } else {
        s2
    }
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
2 | fn longest(s1: &str, s2: &str) -> &str {
    |             ^ expected lifetime parameter
    |
    = help: this function's return type contains a borrowed
    value, but the signature does not say whether it is
    borrowed from `s1` or `s2`
```

---
<style scoped> section{ text-align: left; }</style>

```rust
fn longest<'a>(s1: &'a str, s2: &'a str) -> &'a str {
    if s1.len() > s2.len() {
        s1
    } else {
        s2
    }
}
```

---
`'static` lifetime

---
❌ Entire lifetime of the program

---

<style scoped> section{ text-align: left; }</style>

```rust
let s: &'static str = "Hello, world!";
```

---
# 🍻
