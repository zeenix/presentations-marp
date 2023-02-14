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
Part 1: Dipping Toes

---
Zeeshan Ali Khan

---

## 🇵🇰 🇫🇮 🇬🇧 🇸🇪 🇩🇪

---
<style scoped> section { text-align: left; } </style>
* C
* GStreamer
* GNOME
* Maemo
* Open Source

---

## 🛨  🚁  🐈

---
What is Rust? 🦀

---
Safety + Efficiency

---
Safe languages

---
<style scoped> section { text-align: left; } </style>
* Haskell
* OCaml
* Elang
* ...

---
Efficient languages

---
C/C++

---
Isn't modern C++ safe?

---
Are you a human?

---
![bg fit](msrc-screenshot.png)

---
70% of the security issues

---
Opt-in vs Opt-out

---
![bg fit](nsa-screenshot.png)

---
Beyond memory safety

---
Fearless Concurrency

---
Modern language

---
<style scoped> section { text-align: left; } </style>

* Microsoft
* Google
* Mozilla
* Facebook
* AWS
* Dropbox
* ...

---
OK, OK, can we got on with it?

---
Sure! But first...

---
Mindset & Expectations
<br/>

https://ferrous-systems.com/blog/mindsets-and-expectations

---
Tools

---
<style scoped> section { text-align: left; } </style>
Cargo

```bash
cargo new hello_world
cd hello_world

cargo build
cargo run # build is implied

cargo check # quickly check code will build
```

---
rust-analyzer

---
OK, let's write some Rust!

---
The familiar bits first

---
<style scoped>
  section {
      text-align: left;
  }
</style>

Hello world!

```rust
fn main() {
    println!("Hello, world!");
}
```

---
<style scoped> section { text-align: left; } </style>

Variables

```rust
fn main() {
    let x: i32 = 5;
    // Can be written as:
    let x = 5;
    println!("The value of x is: {}", x);
}
```

---
<style scoped> section{ text-align: left; }</style>

Functions

```rust
fn main() {
    another_function(5);
}

fn another_function(x: i32) {
    println!("The value of x is: {}", x);
}
```

---
Data types

---
Basic types

---
<style scoped> section{ text-align: left; }</style>

* u8, i8, .., u128, i128
* isize and usize
* f32 and f64
* bool
* char
* str and String

---
Arrays and Vectors

---
<style scoped> section{ text-align: left; }</style>

```rust
let a = [1, 2, 3, 4, 5];
println!("The first element of the array is: {}", a[0]);

let v = vec![1, 2, 3, 4, 5];
println!("The first element of the vector is: {}", v[0]);
```

---
Structures

---
<style scoped> section{ text-align: left; }</style>

```rust
struct User {
    username: String,
    email: String,
    sign_in_count: u64,
}

let user = User {
    username: String::from("foo"),
    email: String::from("foo@bar.com"),
    sign_in_count: 1,
};

println!(
    "{} <{}> signed in {} times",
    user.username, user.email, user.sign_in_count,
);
```

---
Tuples
<br/>
(aka anonymous structs)

---
<style scoped> section{ text-align: left; }</style>

```rust
let tup = (500, 6.4, 1); // (i32, f64, i32)
println!("The second value is: {}", tup.1);

let (x, y, z) = tup;
println!("The value of y is: {}", y);
```

---
Powerful Enums 💪🏽

---
Control Flow

---
<style scoped> section{ text-align: left; }</style>

```rust
let a = [1, 2, 3, 4, 5];

for element in a {
    if element == 3 {
        println!("found 3");

        break;
    } else {
        println!("{} != 3", element);
    }
}
```

---
while CONDITION { ... }

---
loop { ... }

---
Mutability

---
<style scoped> section{ text-align: left; }</style>

```rust
let x = 5;
// This should work, right?
x = 6;
```

---
<style scoped> section{ text-align: left; }</style>

```console
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
