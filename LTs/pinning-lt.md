---
marp: true
style: |
  section {
      text-align: center;
      font-size: 40px;
  }
---
# Pinning: A Quick Intro

<br/>
Zeeshan Ali Khan

---
Related to safety

---
Foundation for async/await

---
Self-referential types

---
Rarely needed

---
<style scoped> section{ text-align: left; }</style>

```rust
struct Test {
    a: String,
    b: *const String,
}

impl Test {
    fn new(txt: &str) -> Self {
        Test {
            a: String::from(txt),
            // No address for `a` available yet.
            b: std::ptr::null(),
        }
    }

    fn init(&mut self) {
        let self_ref: *const String = &self.a;
        self.b = self_ref;
    }

    fn a(&self) -> &str {
        &self.a
    }

    fn b(&self) -> &String {
        assert!(!self.b.is_null(), "Test::b called without Test::init being called first");
        unsafe { &*(self.b) }
    }
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
let mut test1 = Test::new("test1");
test1.init();
let mut test2 = Test::new("test2");
test2.init();

println!("a: {}, b: {}", test1.a(), test1.b());
std::mem::swap(&mut test1, &mut test2);
println!("a: {}, b: {}", test2.a(), test2.b());
```

---
<style scoped> section{ text-align: left; }</style>

Expected output:

```sh
a: test1, b: test1
a: test1, b: test1
```

---
<style scoped> section{ text-align: left; }</style>

Actual output:

```sh
a: test1, b: test1
a: test1, b: test2
```

---
Pinning to the rescue

---
`Pin<P>` struct & `Unpin` trait

---
Content of `Pin` can't be moved

---
Unless it implements `Unpin`

---
`Unpin` = "I don't care, move me!"

---
Most types are `Unpin`

---
Let's make use of these types

---
<style scoped> section{ text-align: left; }</style>

```rust
use std::pin::Pin;
use std::marker::PhantomPinned;

struct Test {
    a: String,
    b: *const String,
    _marker: PhantomPinned, // This makes our type `!Unpin` (Not `Unpin`)
}

impl Test {
    fn new(txt: &str) -> Self {
        Test {
            a: String::from(txt),
            b: std::ptr::null(),
            _marker: PhantomPinned,
        }
    }

    fn init(self: Pin<&mut Self>) {
        let self_ptr: *const String = &self.a;
        let this = unsafe { self.get_unchecked_mut() };
        this.b = self_ptr;
    }

    fn a(self: Pin<&Self>) -> &str {
        &self.get_ref().a
    }

    fn b(self: Pin<&Self>) -> &String {
        assert!(!self.b.is_null());
        unsafe { &*(self.b) }
    }
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
    // test1 is safe to move before we initialize it
    let mut test1 = Test::new("test1");
    // Notice how we shadow `test1` to prevent it from being accessed again
    let mut test1 = unsafe { Pin::new_unchecked(&mut test1) };
    Test::init(test1.as_mut());

    let mut test2 = Test::new("test2");
    let mut test2 = unsafe { Pin::new_unchecked(&mut test2) };
    Test::init(test2.as_mut());

    println!("a: {}, b: {}", Test::a(test1.as_ref()), Test::b(test1.as_ref()));
    // Swaps the wrapper only.
    std::mem::swap(&mut test1, &mut test2);
    println!("a: {}, b: {}", Test::a(test2.as_ref()), Test::b(test2.as_ref()));
```

---
Pinning in Practice

---
`Box::pin()` -> `Pin<Box<T>>`

---
`pin_utils`

---
That's it for now 👍

---
Next time: async/await
