---
marp: true
style: |
  section {
      text-align: center;
      font-size: 40px;
  }
---
# zbus 6.0: What's new in zbus?
<br/>

Zeeshan Ali Khan

---
What's zbus?

---
Pure Rust D-Bus library

---
5.0 in Oct 2024

---
25 releases later..

---
Time to break things 💥

---
300+ commits later..

---
## zbus 6.0

---
1\. One crate to rule them all 💍

---
zvariant → `zbus` & `zbus::wire`

---
zbus_names → `zbus::names`

---
Up to 4 dependencies → 1

---
<style scoped> section{ text-align: left; }</style>

```rust
// zbus 5
use zbus::zvariant::{
    LE, OwnedValue, Type, serialized::Context, to_bytes,
};

// zbus 6
use zbus::{
    OwnedValue, Type,
    wire::{LE, serialized::Context, to_bytes},
};
```

---
`zbus::zvariant` still there

---
Deprecated, gone in 7.0

---
Just one `Error` type

---
Only need the wire format?

---
`default-features = false`

---
Fewer deps than zvariant 5 🪶

<!-- 21 → 13 crates: `cargo tree -e normal` of zvariant 5.14 vs. zbus 6 w/o default features. -->
---
GVariant? 👋

---
Moved to the `zgvariant` crate

---
2\. RIP blocking API 🪦

---
<style scoped> section{ text-align: left; }</style>

```rust
// zbus 5
let conn = zbus::blocking::Connection::session()?;
let proxy = MyGreeterProxyBlocking::new(&conn)?;
let reply = proxy.say_hello("Maria")?;

// zbus 6
let reply = zbus::block_on(async {
    let conn = zbus::Connection::session().await?;
    let proxy = MyGreeterProxy::new(&conn).await?;

    proxy.say_hello("Maria").await
})?;
```

---
One `block_on` around the whole program

---
3\. Our own runtime 🏃

---
zbus 5: async-io & friends

---
zbus 6: zruntime

---
Single-threaded

---
Runs on the thread calling `block_on`

---
Faster too 🚀

---
Method call roundtrip: 31 µs → 16.9 µs

---
Signal emit & receive: 13.6 µs → 7.8 µs

<!-- Numbers from https://github.com/z-galaxy/zbus/pull/1975 (p2p, criterion, one machine).
Setting up & tearing down a connection got slower though: 383 µs → 504 µs. -->
---
A crate of its own

---
No zbus needed

---
Tokio? Still first-class

---
4\. Bring your own runtime 🎒

---
<style scoped> section{ text-align: left; }</style>

```rust
use zbus::{Connection, connection::Builder, runtime::traits::Runtime};

async fn connect(runtime: impl Runtime) -> zbus::Result<Connection> {
    Builder::session().runtime(runtime).build().await
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
pub trait Runtime: Send + Sync + 'static {
    type RegisteredIoSource: PollIo;
    type Sleep: Future<Output = ()> + Send + 'static;
    type Task<T>: TaskHandle<T>
    where
        T: Send + 'static;

    fn register_io_source(
        &self,
        source: IoSource,
    ) -> io::Result<Self::RegisteredIoSource>;

    fn sleep(&self, duration: Duration) -> Self::Sleep;

    fn spawn<T>(
        &self,
        name: &str,
        future: impl Future<Output = T> + Send + 'static,
    ) -> Self::Task<T>
    where
        T: Send + 'static;

    // + `spawn_blocking`, w/ a default impl.
}
```

---
I/O readiness, timers & tasks

---
Every async runtime has those

---
5\. On a diet 🥗

---
Default build: 66 → 38 crates

<!-- `cargo tree -e normal` on x86_64 Linux, zbus 5.19.0 vs. 6.0, both w/ default features. -->
---
<style scoped> section{ text-align: left; }</style>

Gone:

* async-io, async-executor, async-task
* async-lock, async-process, blocking
* event-listener, async-broadcast
* proc-macro-crate

---
Pay only for what you use

---
<style scoped> section{ text-align: left; }</style>

New cargo features (all default):

* `proxy` & `service`
* `object-manager`
* `unixexec` & `ibus`
* `tracing`

---
Binary size? 📦

---
GeoClue2 client: 2113 KiB → 1840 KiB

---
Only the features it needs: 1466 KiB 🎉

<!-- zbus's binary-size fixtures, `size` profile (fat LTO, 1 codegen unit, stripped), x86_64
Linux, default runtime. The service: 1896 → 1669 → 1444 KiB. -->
---
CI watches binary size 👀

---
6\. Nicer API ✨

---
Builders: one `?` at the end

---
<style scoped> section{ text-align: left; }</style>

```rust
// zbus 5
let conn = connection::Builder::session()?
    .name("org.zbus.MyGreeter")?
    .serve_at("/org/zbus/MyGreeter", greeter)?
    .build()
    .await?;

// zbus 6
let conn = connection::Builder::session()
    .name("org.zbus.MyGreeter")
    .serve_at("/org/zbus/MyGreeter", greeter)
    .build()
    .await?;
```

---
Properties: just serde

---
<style scoped> section{ text-align: left; }</style>

```rust
// No more `Value` & `OwnedValue` derives.
#[derive(Deserialize, Serialize, Type)]
struct Location {
    latitude: f64,
    longitude: f64,
}

#[interface(name = "org.zbus.Geo1")]
impl Geo {
    #[zbus(property)]
    fn location(&self) -> &Location {
        &self.location
    }
}
```

---
Property errors: any `DBusError`

---
zbus_xml: borrows instead of copying

---
<style scoped> section{ text-align: left; }</style>

Smaller goodies:

* `ConnectionCredentials::into_process_fd`
* `BTreeMap` ⇄ `Value`
* `BitFlags` → `Value`
* `Structure::builder()`

---
7\. Soundness 🔒

---
`FilePath` conversions: sound & lossless

---
Names from a `Value` get validated

---
Non-basic dict keys: now rejected

---
Oh BTW!

---
Flatpak workarounds 🔥

---
Needs xdg-dbus-proxy ≥ 0.1.6

---
Thanks, contributors! 🙏

---
@emilio · @cachebag · @mulkieran · @antonok-edm
@robin-simular · @olkva · @z33ky
@Skyb0rg007 · @ChrisJr404 · @rrnewton

---
Upgrading?

---
Upgrade guide 📖
<br/>

<https://github.com/z-galaxy/zbus/blob/main/book/src/upgrading-to-6.md>

---
That's all folks!
<br/>

<https://github.com/z-galaxy/zbus>
