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
Control Flow

---

```rust
let a = [1, 2, 3, 4, 5];

for element in a {
    println!("the value is: {}", element);
}
```

----
mutability

---