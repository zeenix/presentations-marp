---
marp: true
style: |
  section {
      text-align: center;
      font-size: 50px;
  }
---
# zbus: D-Bus Oxidized 🦀

---
Geoclue

---
Geolocation D-Bus service

---
Written in C

---
What's D-Bus? 🤔

---
Effecient binary IPC protocol

---
Desktop & embedded

---
systemd, GNOME & KDE etc

---
The Broker

---
AKA D-Bus daemon

---
The Bus

---
System & Session

---
peer-to-peer (p2p)

---
Port to Rust

---
How do I D-Bus?

---
There must be a crate for it!

---
dbus-rs

---
libdbus 🙄

---
Multiple issues

---
No CI

---
Still C underneath

---
API over-complicated

---
![bg fit](fb-dbus-rs-post.jpg)

---
![bg fit](fb-dbus-rs-comments.jpg)

---
D-Bus crate from scratch?? 😯

---
How hard can it be? 😂

---
Bottom's up approach

---
After several months

---
zvariant

---
Wire protocol

---
Learning Rust the hard way

---
Fun w/ D-Bus spec

---
zvariant 1.0

---
Broken 😥

---
Another several months

---
zvariant 2.0 🎉

---
`serde`

---
<style scoped> section{ text-align: left; }</style>

```rust
use zvariant::{from_slice, to_bytes, EncodingContext};

// All (de)serialization API needs a context.
let ctxt = EncodingContext::<byteorder::LE>::new_dbus(0);

let t = ("hello", 42, true);
let encoded = to_bytes(ctxt, &t).unwrap();
let decoded: (&str, i32, bool) =
    from_slice(&encoded, ctxt).unwrap();
assert_eq!(decoded, t);
```

---
Back to D-Bus

---
Several ☾ later

---
zbus 1.0 🎉

---
Blocking

---
Some async API

---
Didn't quite fit in

---
Another year of hard work

---
No stardard async runtime

---
zbus 2.0 🎉

---
Async first

---
Blocking wrappers

---
Service

---
<style scoped> section{ text-align: left; }</style>

```rust
use zbus::{ConnectionBuilder, dbus_interface};

struct Greeter { count: u64 }

#[dbus_interface(name = "org.zbus.MyGreeter1")]
impl Greeter {
    async fn say_hello(&mut self, name: &str) -> String {
        self.count += 1;
        format!("Hello {}! I have been called {} times.", name, self.count)
    }
}

let greeter = Greeter { count: 0 };
let _conn = ConnectionBuilder::session()?
    .name("org.zbus.MyGreeter")?
    .serve_at("/org/zbus/MyGreeter", greeter)?
    .build()
    .await?;
//..
```

---
Client

---
<style scoped> section{ text-align: left; }</style>

```rust
use zbus::{Connection, Result, dbus_proxy};

#[dbus_proxy(
    interface = "org.zbus.MyGreeter1",
    default_service = "org.zbus.MyGreeter",
    default_path = "/org/zbus/MyGreeter"
)]
trait MyGreeter {
    async fn say_hello(&self, name: &str) -> Result<String>;
}

let connection = Connection::session().await?;
// `dbus_proxy` macro creates `MyGreaterProxy` based on `Notifications` trait.
let proxy = MyGreeterProxy::new(&connection).await?;
let reply = proxy.say_hello("Maria").await?;
println!("{reply}");
```

---
Goto D-Bus crate

---
World conquered?

---
Not exactly

---
Existing brokers in C

---
CVEs over the years

---
Remote discouraged

---
Let's also oxidize that?

---
Let's first experiment

---
After 2 weekends

---
Basic impl done

---
zbus doing the heavy lifting

---
Windows, MacOS & Linux

---
busd

---
Long way to go still

---
# That's all!

<br/>
https://github.com/dbus2/zbus
https://github.com/dbus2/dbuz
