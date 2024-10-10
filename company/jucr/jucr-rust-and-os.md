---
marp: true
style: |
  section {
      text-align: center;
      font-size: 50px;
  }
---
# JUCR

## end-to-end EV Charging

Built on Rust & Open Source

---
Zeeshan Ali Khan

---

## 🇵🇰 🇫🇮 🇬🇧 🇸🇪 🇩🇪

---
Open Source & Rust

---
JUCR

🚙⌁

---
![bg left:60%](berlin.jpg)

Based in Berlin

---
![bg right:70%](jucr-app.webp)

App

---
Interoperability Issues 😥

---
Charging Stations

---
IOW

---
End-to-end

---
🞋 Reliability

---
Both hardware & software

---
Hardware architecture

---
TODO: arch diagram or description

---
Why not a single CPU?

---
Single point of failure

---
Software architecture

---
Backend in TypeScript

---
Not a great choice

---
C or C++?

---
Nah!

---
We can do better!

---
🦀 Rust

---
🐧 Linux

---
Services & Gateways

---
Services

---
Backend communications

---
Actions & reports

---
Gateways

---
µcontroller comms & control

---
D-Bus API

---
Effecient IPC protocol

---
Desktop, embedded & cloud

---
![zbus logo](zbus-pixels.gif)

## zbus

---
D-Bus made easy

---
Goto D-Bus crate

---
Tokio

---
Async runtime

---
<style scoped> section{ text-align: left; }</style>

```rust
use mini_redis::{client, Result};

#[tokio::main]
async fn main() -> Result<()> {
    // Open a connection to the mini-redis address.
    let mut client = client::connect("127.0.0.1:6379").await?;

    // Set the key "hello" with value "world"
    client.set("hello", "world".into()).await?;

    // Get key "hello"
    let result = client.get("hello").await?;

    println!("got value from the server; result={:?}", result);

    Ok(())
}
```

---
Work-stealing scheduler

---
Thread-pools

---
What about µcontrollers

---
Can't use Tokio

---
No threads

---
No OS

---
Not even an allocator

---
`no_std`

---
On our own? 😱

---
Not at all!

---
Vibrant Rust Embedded community

---
Embassy

---
`no_std` async runtime

---
HALs

---
How does the code look like?

---
<style scoped> section{ text-align: left; }</style>

```rust
#[embassy_executor::main]
async fn main(spawner: embassy_executor::Spawner) {
    let p = embassy_nrf::init(Default::default());

    let led = Output::new(p.P0_13, Level::Low, OutputDrive::Standard);
    unwrap!(spawner.spawn(blinker(led, Duration::from_millis(300))));

    // Other tasks and code goes here.
}

#[embassy_executor::task]
async fn blinker(mut led: Output<'static>, interval: Duration) {
    loop {
        led.set_high();
        Timer::after(interval).await;
        led.set_low();
        Timer::after(interval).await;
    }
}
```

---
Could still get complicated

---
Introducing `firmware-controller` 🎉

---
`controller` macro

---
Owns peripherals

---
Methods

---
Signals

---
Published fields

---
Let's see it in action

---
<style scoped> section{ text-align: left; }</style>

```rust
#[derive(Debug, PartialEq, Copy, Clone)]
pub enum State {
    Enabled,
    Disabled,
}

// The controller struct. This is where you define the state of your firmware.
#[controller]
pub struct Controller {
    #[controller(publish)]
    state: State,
    // Other fields. Note: No all of them need to be published.
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
// The controller implementation. This is where you define the logic of your firmware.
#[controller]
impl Controller {
    // The `signal` attribute marks this method signature (note: no implementation body) as a
    // signal, that you can use to notify other parts of your code about specific events.
    #[controller(signal)]
    pub async fn power_error(&self, description: heapless::String<64>);

    pub async fn enable_power(&mut self) -> Result<(), MyFirmwareError> {
        ...
    }

    pub async fn disable_power(&mut self) -> Result<(), MyFirmwareError> {
        ...
    }
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
    pub async fn enable_power(&mut self) -> Result<(), MyFirmwareError> {
        if self.state != State::Disabled {
            return Err(MyFirmwareError::InvalidState);
        }

        self.set_state(State::Enabled).await;
        self.power_error("Dummy error just for the showcase".try_into().unwrap())
            .await;

        Ok(())
    }

    pub async fn disable_power(&mut self) -> Result<(), MyFirmwareError> {
        if self.state != State::Enabled {
            return Err(MyFirmwareError::InvalidState);
        }

        self.set_state(State::Disabled).await;

        Ok(())
    }
```

---
<style scoped> section{ text-align: left; }</style>

```rust
#[embassy_executor::main]
async fn main(spawner: embassy_executor::Spawner) {
    let mut controller = Controller::new(State::Disabled);

    // Spawn the client task.
    spawner.spawn(client());

    // Run the controller logic.
    controller.run().await;
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
// Just a very silly client that keeps flipping the power state every 1 second.
#[embassy_executor::task]
async fn client() {
    use futures::StreamExt;
    use embassy_time::{Timer, Duration};

    let mut client = ControllerClient::new();
    let mut stream = ControllerState::new().unwrap();

    ...
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
    client.enable_power().await.unwrap();

    while let Some(event) = stream.next().await {
        match event.new {
            State::Enabled => {
                Timer::after(Duration::from_secs(1)).await;
                client.disable_power().await.unwrap();
            }
            State::Disabled => {
                Timer::after(Duration::from_secs(1)).await;
                client.enable_power().await.unwrap();
            }
        }
    }
```

---
The Broker

---
Two Implementations

---
dbus-daemon

---
dbus-broker

---
tokio

---

## Questions?

https://jucr.de
