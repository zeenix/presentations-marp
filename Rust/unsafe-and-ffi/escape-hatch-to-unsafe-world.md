---
marp: true
style: |
  section {
      text-align: center;
      font-size: 40px;
  }
---
# An Escape Hatch to the Unsafe World

<br/>
Zeeshan Ali Khan

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

--
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
Pinning

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

```sh
a: test1, b: test1
a: test1, b: test1
```

---
<style scoped> section{ text-align: left; }</style>

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
    _marker: PhantomPinned,
}

impl Test {
    fn new(txt: &str) -> Self {
        Test {
            a: String::from(txt),
            b: std::ptr::null(),
            _marker: PhantomPinned, // This makes our type `!Unpin`
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
    // Compiler error
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
