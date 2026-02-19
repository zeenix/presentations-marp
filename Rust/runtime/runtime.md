---
marp: true
style: |
  section {
      text-align: center;
      font-size: 40px;
  }
---
# Let's write an async runtime!
<br/>

Zeeshan Ali Khan

---
Before we begin

---
Aassumptions

---
1\. Basic Rust knowledge assumed

---
2\. Including lifetimes & pointers

---
3\. Used async/await

---
Don't like being interrupted

---
Hate being misunderstood

---
Let's get into it

---
<style scoped> section{ text-align: left; }</style>

```rust
async fn hello_world() {
    println!("hello, world!");

    let x = another_async_func().await;

    async move {
        take_x(x).await;
    }.await
}
```

---
How do you call `hello_world`?

---
`main` is not async

---
<style scoped> section{ text-align: left; }</style>

```rust
fn main() {
    // Can't do that!
    greet_world().await;
}
```

---
![bg fit](computer-says-no-no.gif)

---
Entry-point needed

---
Enter runtimes!

---
No runtime in `std`

---
Single- and multithreaded runtimes available

---
tokio and embassy

---
`block_on`

---
<style scoped> section{ text-align: left; }</style>

```rust
use tokio::runtime::Runtime;

fn main() {
    let rt = Runtime::new().unwrap();

    rt.block_on(greet_world())
}
```

---
`main` macro

---
Spawning tasks

---
<style scoped> section{ text-align: left; }</style>

```rust
use std::time::Duration;
use tokio::{spawn, time::sleep};

#[tokio::main]
async main() {
    spawn(async {
        println!("hello, world!");
    });
    spawn(async {
        println!("bye, world!");
    });

    // Do other things or sleep..
    sleep(Duration::from_secs(3)).await;
}
```

---
How do runtimes work? 🤔

---
Before we go there

---
Async under the hood

---
<style scoped> section{ text-align: left; }</style>

```rust
// Rust desugers this:
async fn hello_world() {
    ...
}

// into:
fn hello_world() -> impl Future<Output = ()> {
    ...
}
```

---
What's this `Future` you speak of?

---
![bg fit](future.gif)

---
<style scoped> section{ text-align: left; }</style>

```rust
pub trait Future {
    type Output;

    fn poll(
        // Don't let this scare you!
        self: Pin<&mut Self>, // 🤡
        cx: &mut Context<'_>,
    ) -> Poll<Self::Output>;
}

pub enum Poll<T> {
    Ready(T),
    Pending,
}
```

---
Getting to know the scary 🤡

---
`Pin<Ptr>`

---
<style scoped> section{ text-align: left; }</style>

```rust
struct Foo {
  a: u32,
  // Suppose Rust allowed `'self` lifetime.
  b: &'self u32,  // Invariant `self.b == &self.a`
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
struct Foo {
  a: u32,
  b: *const u32,  // Invariant `self.b == &self.a`
}
```

---
Self-referential types

---
Pinning to the rescue

---
`Pin<Ptr>` struct & `Unpin` trait

---
Guarantee that pointee will not move

---
Unless it implements `Unpin`

---
`Unpin` = "Doesn't matter if I move"

---
Most types are `Unpin`

---
Even our friend `Foo`

---
`!Unpin` explicit

---
Using `PhantomPinned`

---
`Pin` is also `Unpin` 😵‍💫

---
What about `!Unpin` types?

---
2 ways to make them `Unpin`

---
`Box::pin() -> Pin<Box<T>>`

---
`std::pin::pin!` and `futures::pin_mut!` macro

---
We'll uses both later

---
More nuanced topic

---
<style scoped> section{ text-align: left; }</style>

```rust
struct Foo {
  a: u32,
  b: *const u32,  // Invariant `self.b == &self.a`
  make_it_not_unpin: std::marker::PhantomPinned,
}
```

---
What's this to do with async?

---
`Future` impl is a state machine

---
<style scoped> section{ text-align: left; }</style>

```rust
async fn foo() {
  let a = 42_u32; 
  let b = &a;
  bar().await;
  // use b
  ...
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
use std::ptr::null;

fn foo() -> impl Future<Output = ()> {
    let a = 42_u32; 
    let b = &a;

    let mut state = FooStateMachine::Bar { a, b: null() }
    state.b = &state.a;

    Foo { state }
}

struct Foo {
    state: FooStateMachine,
}

enum FooStateMachine {
    // State at bar().await
    Bar { a: u32, b: *const u32 },
    // States for other await points..
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
impl Future for Foo { 
    type Output = ();

    // Note: No `Pin`.
    fn poll(&mut self, cx: &mut Context<'_>) -> Poll<Self::Output> {
        // A lot more nuanced in reality.
        match &mut self.state {
            FooStateMachine::Bar { a, b } => {
                let mut fut = bar();

                match fut.poll(cx) {
                    Poll::Ready(_) => {
                        // Use of `b` here.

                        // If no other await points.
                        return Poll::Ready(()),
                    }
                    Poll::Pending => Poll::Pending,
                }
            }
            // handling for other await points
        }
    }
}
```

---
What if `Foo` moves?

---
`b` becomes invalid

---
And we are unsafe!

---
User only wrote safe Rust

---
Hence `Pin`

---
So far so good?

---
Let's write a runtime!

---
We start with defining traits

---
<style scoped> section{ text-align: left; }</style>

```rust
pub trait Executor {
    type TaskHandle<O>: TaskHandle<Output = O>;

    /// Consume/run the future till completion.
    fn block_on<F>(&mut self, f: F) -> F::Output
    where
        F: Future;

    /// Spawn a task. Single-threaded so manually need to call `run`.
    fn spawn<F>(&mut self, future: F) -> Self::TaskHandle<F::Output>
    where
        F: Future + 'static;

    /// Run all the tasks.
    fn run(&mut self);
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
pub trait TaskHandle {
    type Output;

    fn join(self) -> Self::Output;
}
```

---
Now we implement it

---
but naively

---
<style scoped> section{ text-align: left; }</style>

```rust
// In a child module, so no naming conflict here.
pub struct Executor {
    // We'll look at `Task` a bit later.
    tasks: VecDeque<Task>,
}

impl Executor {
    pub fn new() -> Executor {
        Executor {
            tasks: VecDeque::new(),
        }
    }
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
use std::{pin::Pin, task::{Context, Poll}};

impl super::Executor for Executor {
    fn block_on<F>(&mut self, f: F) -> F::Output
    where
        F: Future,
    {
        futures::pin_mut!(f);

        // Ignore this part for now.
        let mut cx = Context::from_waker(futures::task::noop_waker_ref());

        loop {
            match Pin::new(&mut f).poll(&mut cx) {
                Poll::Ready(val) => return val,
                Poll::Pending => {}
            }
        }
    }
}
```

---
Now to spawning bits

---
<style scoped> section{ text-align: left; }</style>

```rust
pub struct TaskHandle<Ret> {
    receiver: sync::mpsc::Receiver<Ret>,
}

impl<Ret> super::TaskHandle for TaskHandle<Ret> {
    type Output = Ret;

    fn join(self) -> Ret {
        self.receiver.recv().unwrap()
    }
}

struct Task {
    future: Pin<Box<dyn Future<Output = ()>>>,
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
impl super::Executor for Executor {
    type TaskHandle<O> = TaskHandle<O>;

    // `block_on` defined here.

    fn spawn<F>(&mut self, future: F) -> TaskHandle<F::Output>
    where
        F: Future + 'static,
    {
        let (sender, receiver) = sync::mpsc::channel();
        let future = Box::pin(async move {
            let res = future.await;
            sender.send(res).unwrap();
        });
        self.tasks.push_back(Task { future });

        TaskHandle { receiver }
    }
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
impl super::Executor for Executor {
    // ...
    fn run(&mut self) {
        while let Some(task) = self.tasks.pop_front() {
            self.block_on(task.future);
        }
    }
}
```

---
We'll need a test async API

---
<style scoped> section{ text-align: left; }</style>

```rust
use std::{future::Future, io::Result};

pub trait UnixStream: Sized {
    fn pipe() -> Result<(Self, Self)>;

    fn read<'r>(
        &'r mut self,
        buf: &'r mut [u8],
    ) -> impl Future<Output = Result<usize>> + 'r;

    fn write<'r>(
        &'r mut self,
        buf: &'r [u8],
    ) -> impl Future<Output = Result<usize>> + 'r;
}
```

---
A naive impl to go w/ our naive runtime

---
<style scoped> section{ text-align: left; }</style>

```rust
use std::{io::Result, os::unix};

pub struct UnixStream(unix::net::UnixStream);

impl super::UnixStream for UnixStream {
    fn pipe() -> Result<(Self, Self)> {
        unix::net::UnixStream::pair().and_then(|(s1, s2)| {
            s1.set_nonblocking(true)?;
            s2.set_nonblocking(true)?;

            Ok((Self(s1), Self(s2)))
        })
    }
```

---
<style scoped> section{ text-align: left; }</style>

```rust
    fn read<'r>(
        &'r mut self,
        buf: &'r mut [u8],
    ) -> impl Future<Output = Result<usize>> + 'r {
        Read {
            stream: &mut self.0,
            buf,
        }
    }

    fn write<'r>(
        &'r mut self,
        buf: &'r [u8],
    ) -> impl Future<Output = Result<usize>> + 'r {
        Write {
            stream: &mut self.0,
            buf,
        }
    }
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
pub struct Read<'r> {
    stream: &'r mut unix::net::UnixStream,
    buf: &'r mut [u8],
}

impl Future for Read<'_> {
    type Output = Result<usize>;

    fn poll(
        self: Pin<&mut Self>,
        _cx: &mut Context<'_>,
    ) -> Poll<Self::Output> {
        use std::io::Read;

        let this = self.get_mut();
        match this.stream.read(this.buf) {
            Ok(len) => Poll::Ready(Ok(len)),
            Err(e) if e.kind() == io::ErrorKind::WouldBlock => Poll::Pending,
            Err(e) => Poll::Ready(Err(e)),
        }
    }
}

// `Write` is almost identical
```

---
Let's try it

---
<style scoped> section{ text-align: left; }</style>

```rust
let mut executor = Executor::new();
let (mut tx, mut rx) = UnixStream::pipe().unwrap();

let handle = executor.spawn(async move {
    let mut buf = [0; 50];
    let len = rx.read(&mut buf).await.unwrap();
    let msg = from_utf8(&buf[..len]).unwrap();
    println!("\tMessage from Uncle Leo: {}", msg);
});

executor.block_on(async move {
    let msg = b"Hellllo! Jerry! Hellllo!";
    let written = tx.write(msg).await.unwrap();
    assert_eq!(written, msg.len());
});

executor.run();

handle.join();
```

---
It works!!

---
<style scoped> section{ text-align: left; }</style>

```rust
let handle1 = executor.spawn(async move {
    let mut buf = [0; 50];
    let len = rx.read(&mut buf).await.unwrap();
    let msg = from_utf8(&buf[..len]).unwrap();
    println!("\tMessage from Uncle Leo: {}", msg);
});

let handle2 = executor.spawn(async move {
    let msg = b"Hellllo! Jerry! Hellllo!";
    let written = tx.write(msg).await.unwrap();
    assert_eq!(written, msg.len());
});

executor.run();

handle1.join();
handle2.join();    
```

---
This one hangs 😞

---
Why?

---
Multiple issues

---
<style scoped> section{ text-align: left; }</style>

```rust
impl super::Executor for Executor {
    // ...
    fn run(&mut self) {
        // Way too naive!
        //
        // One task at a time (beats the whole point). This is our issue.
        while let Some(task) = self.tasks.pop_front() {
            self.block_on(task.future);
        }
    }
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
impl Future for Read<'_> {
    type Output = Result<usize>;

    fn poll(
        self: Pin<&mut Self>,
        _cx: &mut Context<'_>,
    ) -> Poll<Self::Output> {
        use std::io::Read;

        let this = self.get_mut();
        match this.stream.read(this.buf) {
            Ok(len) => Poll::Ready(Ok(len)),
            // How would caller know when to call again?
            Err(e) if e.kind() == io::ErrorKind::WouldBlock => Poll::Pending,
            Err(e) => Poll::Ready(Err(e)),
        }
    }
}
```

---
Also `block_on` super inefficient!

---
<style scoped> section{ text-align: left; }</style>

```rust
// Busy loops
loop {
    match Pin::new(&mut f).poll(&mut cx) {
        Poll::Ready(val) => return val,
        Poll::Pending => {}
    }
}
```

---
We can do better

---
<style scoped> section{ text-align: left; }</style>

```rust
// Remmber this? I asked you to Ignore it?
let mut cx = Context::from_waker(futures::task::noop_waker_ref());
```

---
`Waker`

---
<style scoped> section{ text-align: left; }</style>

```rust
use std::{task::Wake, Thread};

/// A waker that wakes up the underlying thread when called.
struct ThreadWaker(Thread);

impl Wake for ThreadWaker {
    fn wake(self: Arc<Self>) {
        self.0.unpark();
    }
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
use std::thread::{self, park};

fn block_on<F>(&mut self, f: F) -> F::Output
where
    F: Future,
{
    pin_mut!(f);

    // Home work: See `std` docs for details on how this works.
    let waker = Arc::new(ThreadWaker(thread::current())).into();
    let mut cx = Context::from_waker(&waker);

    loop {
        match Pin::new(&mut f).poll(&mut cx) {
            Poll::Ready(val) => return val,
            Poll::Pending => {}
        }

        // Sleep so we don't busy loop.
        park();
    }
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
fn run(&mut self) {
    let waker = Arc::new(ThreadWaker(thread::current())).into();
    let mut cx = Context::from_waker(&waker);

    while !self.tasks.is_empty() {
        self.tasks
            .retain_mut(|task| match Pin::new(&mut task.future).poll(&mut cx) {
                Poll::Ready(_) => false, // task done, remove it.
                Poll::Pending => true,   // task still pending, keep it.
            });

        if !self.tasks.is_empty() {
            park();
        }
    }
}
```

---
`Future` impls need changes too

---
<style scoped> section{ text-align: left; }</style>

```rust

impl Future for Read<'_> {
    type Output = Result<usize>;

    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
        use std::io::Read;

        let this = self.get_mut();
        match this.stream.read(this.buf) {
            Ok(len) => Poll::Ready(Ok(len)),
            Err(e) if e.kind() == io::ErrorKind::WouldBlock => {
                let waker = cx.waker();
                // Wir haben ein Problem!
                //
                // We need to call `waker.wake()` when data is read to be read but
                // that  an block and we MUST NOT block here.

                Poll::Pending
            }
            Err(e) => Poll::Ready(Err(e)),
        }
    }
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
enum Event {
    Read,
    Write,
}

/// Poll the given FD for specified event.
fn poll<Fd: AsFd>(fd: &Fd, event: Event) {
    // Won't go into this impl.
}

fn wake_on_event<Fd: AsFd>(fd: &Fd, event: Event, waker: &Waker) {
    let fd = fd.as_fd().try_clone_to_owned().unwrap();
    let waker = waker.clone();

    thread::spawn(move || {
        poll(&fd, event);

        waker.wake();
    });
}
```

---
<style scoped> section{ text-align: left; }</style>

```rust
// Only part of `Future` impl of `Read` that changes:
Err(e) if e.kind() == io::ErrorKind::WouldBlock => {
    wake_on_event(&this.stream, Event::Read, cx.waker());

    Poll::Pending
}
```

----
Does it work now? 😅

---
It does! 🎉

---
<style scoped> section{ text-align: left; }</style>

```console
❯ cargo r
   Compiling zruntime v0.1.0 (/home/zeenix/experiments/zruntime)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.20s
     Running `target/debug/zruntime`

    Message from Uncle Leo: Hellllo! Jerry! Hellllo!
❯
```

---
Very inefficient runtime

---
It will have to do for now

---
That's all folks!
<br/>

<https://github.com/zeenix/experiments/blob/master/zruntime>
