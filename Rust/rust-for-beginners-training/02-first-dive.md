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
No null pointers

---
<style scoped> section{ text-align: left; }</style>

```rust
enum Option<T> {
    None,
    Some(T),
}
```
