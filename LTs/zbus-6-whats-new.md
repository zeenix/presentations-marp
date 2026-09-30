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
Time to break things 💥

---
## zbus 6.0

---
One crate to rule them all 💍

---
zvariant & zbus_names → zbus

---
`zbus::zvariant` still works (deprecated)

---
GVariant → `zgvariant` crate 👋

---
RIP blocking API 🪦

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
Our own runtime: zruntime 🏃

---
Runs on the thread calling `block_on`

---
Method call roundtrip: 31 µs → 16.9 µs 🚀

<!-- vs. zbus 5's async-io backend, from https://github.com/z-galaxy/zbus/pull/1975 (p2p,
criterion, one machine). Signals: 13.6 µs → 7.8 µs. Setting up & tearing down a connection got
slower though: 383 µs → 504 µs. -->
---
Tokio? Still first-class

---
Or bring your own runtime 🎒

---
<style scoped> section{ text-align: left; }</style>

```rust
// `runtime`: any `impl zbus::runtime::traits::Runtime`.
let conn = connection::Builder::session()
    .runtime(runtime)
    .build()
    .await?;
```

---
On a diet 🥗

---
Default build: 66 → 38 crates

<!-- `cargo tree -e normal` on x86_64 Linux, zbus 5.19.0 vs. 6.0, both w/ default features. Gone:
async-io, async-executor, async-task, async-lock, async-process, blocking, event-listener,
async-broadcast & proc-macro-crate. -->
---
<style scoped> section{ text-align: left; }</style>

Opt out of what you don't use:

* `proxy` & `service`
* `object-manager`
* `unixexec` & `ibus`
* `tracing`

---
GeoClue2 client: 2113 KiB → 1840 KiB

---
Only the features it needs: 1466 KiB 🎉

<!-- zbus's binary-size fixtures, `size` profile (fat LTO, 1 codegen unit, stripped), x86_64
Linux, default runtime. The service: 1896 → 1669 → 1444 KiB. -->
---
Nicer API ✨

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
Easier properties

---
Thanks, contributors! 🙏
<br/>

@emilio · @cachebag · @mulkieran · @antonok-edm
@robin-simular · @olkva · @z33ky
@Skyb0rg007 · @ChrisJr404 · @rrnewton

---
Upgrade guide 📖
<br/>

<https://github.com/z-galaxy/zbus/blob/main/book/src/upgrading-to-6.md>

---
That's all folks!
<br/>

<https://github.com/z-galaxy/zbus>
