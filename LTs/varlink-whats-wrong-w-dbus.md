---
marp: true
style: |
  section {
      text-align: center;
      font-size: 40px;
  }
---
# Varlink? What's wrong w/ D-Bus

<br/>
Zeeshan Ali Khan

---
What's D-Bus? 🤔

---
Effecient binary IPC protocol

---
Desktop & embedded

---
systemd, GNOME & KDE etc

---
More than just IPC

---
API

---
Low-level: Message passing

---
High-level

---
<style scoped> section{ text-align: left; }</style>
Objects

```
/org/freedesktop/GeoClue2/Manager
/org/freedesktop/GeoClue2/Client
/org/freedesktop/GeoClue2/Location/0
/org/freedesktop/GeoClue2/Location/1
...
```

---
<style scoped> section{ text-align: left; }</style>
Interfaces

```
org.freedesktop.GeoClue2.Manager
org.freedesktop.GeoClue2.Client
org.freedesktop.GeoClue2.Location
...
```

---
<style scoped> section{ text-align: left; }</style>
Methods

```
org.freedesktop.GeoClue2.Manager.GetClient(OUT o client)
org.freedesktop.GeoClue2.Client.Start()
org.freedesktop.GeoClue2.Client.Stop()
```

---
<style scoped> section{ text-align: left; }</style>
Properties

```
org.freedesktop.GeoClue2.Location.Latitude
org.freedesktop.GeoClue2.Location.Longitude
org.freedesktop.GeoClue2.Location.Altitude
```

---
<style scoped> section{ text-align: left; }</style>
Signals

```
org.freedesktop.GeoClue2.Client.LocationUpdated(o old, o new)
```

---
The Broker

---
AKA D-Bus daemon

---
AKA The Bus

---
System & Session

---
peer-to-peer (p2p)

---
Varlink

---
JSON over sockets

---
Especially Unix sockets

---
p2p

---
Interfaces & Methods

---
Continuous replies

---
Libraries

---
C, Go, Java, Python,

---
Most importantly!!

---
![bg fit](cuddlyferris.png)

---
Advantages over D-Bus

---
Light weight

---
Low-latency

---
D-Bus is showing its age

---
E.g Null not supported

---
Disadvantages

---
No built-in security

---
No built-in policy

---
PolicyKit speaks D-Bus

---
JSON is inefficient

---
Who is using it?

---
Not many (yet)

---
Systemd

---
That's it for now 👍
