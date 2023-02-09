---
marp: true
style: |
  section {
      text-align: center;
      font-size: 40px;
  }
---
# Rust for beginners

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
C++ is not safe

---
![bg fit](msrc-screenshot.png)

---
70% of the security issues

---
Opt-in vs Opt-out

---
Beyond memory safety

---

* Microsoft
* Google
* Mozilla
* Facebook
* AWS
* Dropbox
* ...

---
Ok, let's write some Rust!

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
u8, i8, .., u128, i128, isize, usize

---
Structures

---
<style scoped> section{ text-align: left; }</style>
Definition

```rust
struct User {
    username: String,
    email: String,
    sign_in_count: u64,
}
```

---
<style scoped> section{ text-align: left; }</style>
Instantiating & Using

```rust
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
