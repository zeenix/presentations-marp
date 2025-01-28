---
marp: true
style: |
  section {
      text-align: center;
      font-size: 50px;
  }
---
# How I optimized zbus by 95%

Zeeshan Ali Khan

---
About myself

---
Open Source & Linux Systems Engineer

---

## 🇵🇰 🇫🇮 🇬🇧 🇸🇪 🇩🇪

---
🦀

---
JUCR

🚙⌁

---
What's zbus?

---
Pure Rust D-Bus library

---
Ok and WTH is D-Bus? 🤔

---
Effecient binary IPC protocol

---
Before zbus..

---
There was only dbus-rs

---
libdbus wrapper

---
Multiple issues

---
zbus

---
![bg fit](zbus-pixels.gif)

---
Goto D-Bus crate

---
![bg fit](zbus-alberto-tweet.jpg)

---
What's the problem then?

---
Before we go there..

---
zvariant

---
serde-based since 2.0

---
Fundamental incompatibilites

---
`Option<T>`

---
No Nullable types in D-Bus 😥

---
Empty Array Alignment

---
wikipedia.org/wiki/Data_structure_alignment

---
<style scoped> section{ text-align: left; }</style>

```rust
impl serde::Serializer for MySerializer {
    type SerializeSeq = MySeqSerializer;

    ...

    fn serialize_seq(
        self,
        len: Option<usize>,
    ) -> Result<Self::SerializeSeq, Self::Error> {
        unimplemented!()
    }
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
impl serde::SerializeSeq for MySeqSerializer {
    ...

    // Never called for empty sequences.
    fn serialize_element<T: ?Sized + Serialize>(
        &mut self,
        value: &T,
    ) -> Result<(), Self::Error>
    {
        unimplemented!()
    }

    fn end(self) -> Result<(), Self::Error> {
        unimplemented!()
    }
}
```

---
How did I solve it?

---
Enter D-Bus type signatures

`(iba{sv})`

---
`Type` trait

---
<style scoped> section{ text-align: left; }</style>

```rust
// over-simplified.
struct Signature<'a>(Cow<'a, str>);

trait Type {
    fn signature() -> Signature<'static>;
}

trait DynamicType {
    fn dynamic_signature(&self) -> Signature<'_>;
}
```

---
Meh!

---
`Type` derive

---
<style scoped> section{ text-align: left; }</style>

```rust
#[derive(Serialize, Deserialize, Type)]
//                               ^^^^
struct MyStruct {
    a: u32,
    b: String,
    c: Vec<u8>,
}
```

---
impls for commonly used types

---
Including external crates

e.g `chrono`, `uuid`, etc

---
Too many allocations

---
Not `const` 😥

---
Oh well. 🤷

---
What about performance?

---
https://github.com/KillingSpark/rust-dbus-comparisons

---
`cargo bench` + `criterion`

---
<style scoped> section{ text-align: right; font-size: 30px; }</style>

| Library  | Mixed  | StrArray | BigArray | Enc + Send |
|----------|--------|----------|----------|------------|
| dbus-rs  | 168 µs | 1.33 ms  | 377 µs   | 262 µs     |
| zvariant |  54 µs | 1.05 ms  | 538 µs   | 246 µs     |

---
Not too bad?

---
Bar is low

---
Biggest bottleneck?

---
Introducing `cargo flamegraph`

---
![bg fit](zbus-before-opt-flamegraph.png)

---
Signature parsing

---
Especially large arrays

---
Many sleepless nights

---
![bg fit](bet-hes-thinking-about-zbus.jpg)

---
Years go by..

---
`postcard` & `postcard-rpc`

---
<style scoped> section{ text-align: left; }</style>

```rust
trait Schema {
    const SCHEMA: &'static NamedType;
}
```

---
![bg fit](dicaprio-pointing.gif)

---
Rethink Signature Representation

---
<style scoped> section{ text-align: left; }</style>

```rust
enum Signature {
    Unit,
    Bool,
    Byte,
    Int16,
    ...
    Array(Child),
    Struct(Fields),
    Dict { key: Child, value: Child },
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
enum Child {
    /// A static child signature.
    Static { child: &'static Signature },
    /// A dynamic child signature.
    Dynamic { child: Box<Signature> },
}

enum Fields {
    Static { fields: &'static [&'static Signature] },
    Dynamic { fields: Box<[Signature]> },
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
trait Type {
    const SIGNATURE: &'static Signature;
}

trait DynamicType {
    fn signature(&self) -> Signature;
}
```

---
(De)serializer don't parse anymore 👍️

---
Well, not exactly..

---
Variants

---
More robust & efficient parser

---
`nom`

---
`winnow`

---
Parse once

---
It works!!

---
Performs better?

---
<style scoped> section{ text-align: right; font-size: 30px; }</style>

| Library    | Mixed  | StrArray    | BigArray | Enc + Send |
|------------|--------|-------------|----------|------------|
| dbus-rs    | 168 µs | 1.33 **ms** | 377 µs   | 282 µs     |
| zvariant 3 |  54 µs | 1.05 **ms** | 538 µs   | 246 µs     |
| zvariant 5 |   9 µs |  202 **µs** |  47 µs   | **NaN**    |

---
🙌

---
You promised 95%! 😡

---
Hardware-dependent

---
Type-dependent

---
The Future?

---
![bg fit](future.gif)

---
Varlink

---
JSON

---
Better serde-compatiblity

---
Parsing costs?

---
Context-switching is expensive

---
p2p

---
Other optimization opportunities

---
Many connections -> exterior mutability

---
Avoid allocations/cloning

---
`no-std`

---
`no-alloc`

---
A Rust crate exists

---
Guess the name?

---
Yes, it's `Varlink`

---
<style scoped> section{ text-align: left; }</style>

A few issues

* Blocking API
* Designed for code-generation
* Lots of allocations
* Unmaintained

---
We can do better

---
I have a plan

---
A bit vague but...

---
...based on experience

---
The same crate (hopefully!)

---
D-Bus not going away

---
Legacy

---

## Questions?

https://github.com/dbus2/zbus
