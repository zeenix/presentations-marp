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

```console
error[E0382]: borrow of moved value: `s1`
```

---
Copy vs. Move

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
Enums

---
<style scoped> section{ text-align: left; }</style>

The boring kind

```rust
enum IpAddrKind {
    V4,
    V6,
}

let four = IpAddrKind::V4;
let six = IpAddrKind::V6;
```

---
<style scoped> section{ text-align: left; }</style>
The interesting kind

```rust
enum IpAddr {
    V4(u8, u8, u8, u8),
    V6(String),
}

let home = IpAddr::V4(127, 0, 0, 1);
let loopback = IpAddr::V6(String::from("::1"));
```

---
<style scoped> section{ text-align: left; }</style>
They are super powerful

```rust
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(i32, i32, i32),
}
```

---
Pattern matching

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
Generics

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

# ☕
