---
marp: true
style: |
  section {
      text-align: center;
      font-size: 50px;
  }
---
# Forget zbus, zlink is the future of IPC in Rust

Zeeshan Ali Khan

---
About myself

---
Recap

---
What's zbus?

---
Pure Rust D-Bus library

---
What's Varlink?

---
An IPC mechanism

---
Systemd

---
JSON

---
Debates w/ Lennart

---
Parsing costs?

---
Context-switching is expensive

---
p2p

---
Denial Phase

---
I'll show him!

---
Let's benchmark

---
<https://github.com/zeenix/json-vs-bin>

---
<style scoped> section{ text-align: right; font-size: 30px; }</style>

| Format | Data Kind     | Big (µs) | Small (µs) |
| ------ | ------------- | -------- | ---------- |
| JSON   | HashMap-heavy |  340.2   |  **59.2**  |
| D-Bus  | HashMap-heavy |  399.1   |  **78.6**  |
| JSON   | Vector-based  | 5690.3   | 317.9      |
| D-Bus  | Vector-based  | 3649.8   | 180.5      |

---
Encoding+decoding Speed Only

---
What about size?

---
<style scoped> section{ text-align: right; font-size: 30px; }</style>

| Format | Data Kind     | Big (KiB) | Small (KiB) |
| ------ | ------------- | --------- | ----------- |
| JSON   | HashMap-heavy |   80.99   |  **14.87**  |
| D-Bus  | HashMap-heavy |   97.74   |  **18.52**  |
| JSON   | Vector-based  | 2311.23   | 132.98      |
| D-Bus  | Vector-based  |  933.36   |  47.43      |

---
Perhaps not a bad idea 🤔

---
Other Advantages?

---
Simple

---
IPC == Log

---
Pipelining

<!-- Sequential processing guarantee -->
---
Rust-specific Advantages?

---
`serde_json`

---
Nullable types 🎉

---
`Option<T>`

---
Connection sharing in D-Bus

---
Receive Pipeline in `zbus`

---
![bg fit](zbus-msg-broadcast.svg)

---
`Arc<T>` to the rescue!

---
![bg fit](zbus-msg-bytes.svg)

---
<style scoped> section { text-align: left; } </style>

* 2x Copied
* Atomics
* Interior Mutability
* Task/thread scheduling latencies

<!-- Copies even for single consumer/task -->
---
In the Varlink world..

---
P2P w/o Handshake == Cheap Connections

---
Cheap Connections == Unlimited Connections

---
![bg fit](zlink-msg-bytes.svg)

---
<style scoped> section { text-align: left; } </style>

* ~~Atomics~~
* 1x Copy
* Exterior Mutability
* ~~Socket Reader task/thread~~

---
`no_std` possible

---
You know what?

---
`no_alloc` probably also

---
Why `no_alloc`??

---
![bg fit](jucr-sw-arch.svg)

---
Cut the Middleperson

---
Acceptance Phase

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
* Unmaintained

---
We can do better

---
Since I wrote `zbus`

---
`zlink`

---
<style scoped> section { text-align: left; } </style>

* async
* no_std & no_alloc support
* Code-generation not required
* Lessons from `zbus`
* Chaining/Pipelining

---
![bg fit](zlink-arch.svg)

---
Varlink & Rust: a match made in heaven?

---
Yes & No

---
Designed by C devs

---
No size header (null-terminated)

---
`memchr`

---
Encoding encourages allocation/re-parsing

<!-- pipelining & null-termination -->
---
<style scoped> section { text-align: left; } </style>

```json
{
  "method": "org.example.ftl.CalculateConfiguration",
  "parameters": {
    "longitude": 27.13,
    "latitude": -12.4,
    "distance": 48732498234
  }
}
```

---
Assume field order

<!-- Should be part of the spec -->
---
Other problems

---
`no_alloc` very hard

---
🐞🐞🐞

---
<style scoped> section { text-align: left; } </style>

* serde
* rustc
* ...

---
The status?

---
Low-level API ✅

---
High-level Client API ✅

---
Show me the ~~code~~ API!

---
<style scoped> section { text-align: left; } </style>

```rust
// The client proxy - this implements the trait for `Connection<S>`
#[zlink::proxy("org.example.Calculator")]
trait CalculatorProxy {
    async fn add(
        &mut self,
        a: f64,
        b: f64,
    ) -> zlink::Result<Result<CalculationResult, CalculatorError<'_>>>;
}

#[derive(Debug, Serialize, Deserialize)]
struct CalculationResult {
    result: f64,
}

#[derive(Debug, zlink::ReplyError)]
#[zlink(interface = "org.example.Calculator")]
enum CalculatorError<'a> {
    DivisionByZero {
        message: &'a str
    },
    ...
}
```

<!-- Similar to zbus::proxy  -->

---
<style scoped> section { text-align: left; } </style>

```rust
// Connect to the calculator service
let mut conn = zlink::unix::connect(SOCKET_PATH).await?;

// Use the proxy-generated methods
let result = conn.add(5, 3).await?.unwrap();
assert_eq!(result.result, 8.0);

let result = conn.multiply(4, 7).await?.unwrap();
assert_eq!(result.result, 28.0);
```

---
Pipelining

---
<style scoped> section { text-align: left; } </style>

* `chain_<method_name>` variants
* `<TraitName>Chain` trait

---
<style scoped> section { text-align: left; } </style>

```rust
let mut conn = zlink::unix::connect(SOCKET_PATH).await?;

// Use the proxy-generated methods
let mut replies = conn
    .chain_add(5, 3)?
    .multiply(4, 7)?
    // chain other methods..
    .send()
    .await?;

while let Some(result) = replies.try_next()?.await {
    println!("{result}");
}
```

---
Other goodies

---
<style scoped> section { text-align: left; } </style>

* Multiple replies
* Introspection

---
~~Low~~Mid-level Server API ✅

---
⚠️

---
<style scoped> section { text-align: left; } </style>

```rust
use zlink::{Call, MethodReply, Reply, Service};

impl zlink::Service for Calculator {
    type MethodCall<'de> = CalculatorMethod;
    type ReplyParams<'ser> = CalculatorReply<'ser>;
    type ReplyStreamParams = ();
    type ReplyStream = futures_util::stream::Empty<Reply<()>>;
    type ReplyError<'ser> = CalculatorError<'ser>;

    async fn handle(
        &mut self,
        call: Call<Self::MethodCall<'_>>,
    ) -> MethodReply<Self::ReplyParams<'_>, Self::ReplyStream, Self::ReplyError<'_>> {
      ...
    }
}
```

---
😱

---
High-level Server API 👨‍🏭

---
Baremetal embedded ❓

---
![bg fit](jucr-sw-arch.svg)

---
![bg fit](jucr-sw-new-arch.svg)

---
Extreme low-latency requirements

---
`no_alloc` complicates

---
<style scoped> section { text-align: left; } </style>

Still avoid

* allocations
* atomics
* interior mutability

---
Custom JSON (de)serializer 🤔

<!-- ~~null-byte detection~~ -->
---
A reminder before we finish..

---
D-Bus not going away

---
Legacy

---

## Questions?

<https://github.com/zeenix/zlink>
