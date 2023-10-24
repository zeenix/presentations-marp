---
marp: true
style: |
  section {
      text-align: center;
      font-size: 40px;
  }
---
# async/await
<br/>
The good, the bad and the ugly.

---
Who am I?

---
Zeeshan Ali Khan

---
FOSS

---
# 🛩 🚁 🐈

---
🦀

---
Async Foundations WG 

---
Before we begin

---
Basic Rust knowledge assumed

---
Let's get into it!

---
Why async?

---
Concurrent programming

---
Why not just use threads?

---
Overhead

---
CPU- vs I/O-bound

---
Waiting concurrently

---
Why not callbacks?

---
Callback chains

---
Look&feel of synchronous code

---
<style scoped> section{ text-align: left; }</style>

```rust
async fn hello_world() {
    println!("hello, world!");
}

async fn greet_world() {
    hello_world().await;
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
fn main() {
    greet_world();
}
```

---
Builds and runs

---
but doesn't print anything

---
Why on earth not?? 😦

---
<style scoped> section{ text-align: left; }</style>

```rust
warning: unused `Future` that must be used
  --> src/main.rs:11:5
   |
11 |     greet_world();
   |     ^^^^^^^^^^^^^^
   |
   = note: futures do nothing unless you `.await` or
           poll them
```

---
What does that even mean?

---
async functions return a `Future` type

---
<style scoped> section{ text-align: left; }</style>

```rust
fn hello_world() -> impl Future<Output = ()>;
```

---
![bg fit](future.gif)

---
<style scoped> section{ text-align: left; }</style>

```rust
pub trait Future {
    type Output;

    fn poll(
        self: Pin<&mut Self>,
        cx: &mut Context<'_>,
    ) -> Poll<Self::Output>;
}

pub enum Poll<T> {
    Ready(T),
    Pending,
}
```

---
Futures are inert

<!-- # note: Unlike in other languages. -->

---
Entry-point needed

---
Let's .await the future!

---
<style scoped> section{ text-align: left; }</style>

```rust
fn main() {
    greet_world().await;
}
```

---
![bg fit](computer-says-no-no.gif)

---
<style scoped> section{ text-align: left; }</style>

```rust
error[E0728]: `await` is only allowed inside `async`
              functions and blocks
```

---
Enter the runtimes!

---
No built-in runtime

---
Single- and multithreaded runtimes available

---
tokio and async-std

---
<style scoped> section{ text-align: left; }</style>

```rust
use async_std::task;

fn main() {
    task::block_on(greet_world())
}
```

---
async blocks

---
<style scoped> section{ text-align: left; }</style>

```rust
use async_std::task;

fn main() {
    task::block_on(async {
        println!("Hello, world!");
    })
}
```

---
What about concurrency?

---
Spawning and tasks

---
<style scoped> section{ text-align: left; }</style>

```rust
use std::{thread::sleep, time::Duration};
use async_std::task::spawn;

spawn(async {
    println!("hello, world!");
});
spawn(async {
    println!("bye, world!");
});

// Do other things or sleep..
sleep(Duration::from_secs(3));
```

---
Tasks are futures too!

---
<style scoped> section{ text-align: left; }</style>

```rust
use async_std::task::spawn;

let task = spawn(async {
    println!("hello, world!");
});

task.await;
```

---
Combining Futures

---
<style scoped> section{ text-align: left; }</style>

```rust
use futures::join;

let fut1 = async {
    println!("hello, world!");
};
let fut2 = async {
    println!("bye, world!");
};

join!(fut1, fut2);
```

---
select, map, etc

---
Streams

---
AKA Async Iterator

---
<style scoped> section{ text-align: left; }</style>

```rust
use futures::stream::{self, StreamExt};

let mut stream = stream::repeat(7);

assert_eq!(stream.next().await, Some(7));
assert_eq!(stream.next().await, Some(7));
```

---
Similar API to Iterator

<!-- # futures crate -->

---
I promised bad & ugly

---
Runtime-agnostic libraries

---
Which runtime?

---
Why no built-in runtime?

---
No 👠 fits all

---
smol-rs

---
async sandwich footgun

---
<style scoped> section{ text-align: left; }</style>

```rust
block_on(async {
    block_on(async {
        // Some async work.
    });
});
```

---
Async in Traits

---
![bg fit](why-async-trait-hard-blog.png)

---
Async is zero-cost in Rust

---
`async_trait`

---
99% of cases covered

---
<style scoped> section{ text-align: left; }</style>

```rust
use async_trait::async_trait;

#[async_trait]
trait Advertisement {
    async fn run(&self);
}
```

---
Rest assured!

---
People are working on these issues.

---
That's all folks!
<br/>

https://rust-lang.github.io/async-book
