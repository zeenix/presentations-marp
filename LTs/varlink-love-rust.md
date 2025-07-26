---
marp: true
style: |
  section {
      text-align: center;
      font-size: 50px;
  }
---
# Varlink ♥️ Rust?

---
Zeeshan Ali Khan

---
What's Varlink?

---
An IPC mechanism

---
Systemd

---
D-Bus

---
Existing `varlink` crate

---
<style scoped> section { text-align: left; } </style>

* Not async
* Code-generation-based
* Unmaintained

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
Varlink & Rust: a match made in heaven?

---
Yes & No

---
Designed by C devs

---
<style scoped> section { text-align: left; } </style>

* No size header (null-terminated)
* JSON encoding encourages allocation (or re-parsing)

---
OTOH..

---
<style scoped> section { text-align: left; } </style>

* Great JSON APIs in Rust
* Many connections
  * Fewer allocations/cloning
  * Fewer atomics

---
The status?

---
<style scoped> section { text-align: left; } </style>

* Low-level API ✅
* High-level API ☑️
  * Client ☑️
  * Server
* Baremetal embedded

---
<https://github.com/zeenix/zlink>