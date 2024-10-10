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
Could still get complicated

---
firmware-controller

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
