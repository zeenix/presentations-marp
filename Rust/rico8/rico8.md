---
marp: true
style: |
  section {
      text-align: center;
      font-size: 40px;
  }
---
# RICO-8
<br/>

A new fun way to learn & master Rust

---
## PICO-8
<br/>

By Lexaloffle

---
A fantasy console 🎮

---
A computer that never existed

---
Works on retro consoles

---
Tiny on purpose

---
The limits are the point

---
Make a whole game in an evening

---
128×128 screen

---
16 fixed colors

---
256 sprites, 8×8 each

---
A tile map

---
4 sound channels

---
SFX + music, built-in trackers

---
Five editors, all on the machine

---
code · sprite · map · sfx · music

---
Lua for the code

---
Limited tokens

---
Carts are PNG images 🖼️

---
Web export

---
A whole community to share to

---
Awesome!

---
Talking of 80s childhood

---
![bg fit](airwolf-titles.jpg)

---
![bg fit](airwolf-retro-game.png)

---
Decided to write my own

---
My pico8 repo

---
So all good then?

---
Not quite

---
1\. Couldn't ♥️ Lua

---
I need types!

---
1-indexed 😬

---
Limit on code rather than runtime resources

---
No libraries

---
2\. Closed source, and paid

---
I wanted Rust! 🦀

---
Types. Cargo. rust-analyzer.

---
Catch it at compile time

---
Retirement plan

---
Fable 5

---
Machine does the boring part

---
I do the exciting part

---
Prompt

---
PICO-8 replica

Same feel

---
Same constraints

---
Same charm

---
But the games are Rust

---
Written in Rust

---
Rust → WebAssembly → sandbox

---
No limits on code

---
Limits on resources

---
128K

---
In 30 mins

---
Working impl

---
Lots of minor issues

---
Most ironed out

---
## RICO-8

---
What's cart dev like?

---
<style scoped> section{ text-align: left; }</style>

```rust
use rico8::*;

struct MyGame { x: f32, y: f32 }

impl Game for MyGame {
    fn update(&mut self, ctx: &mut Context) {
        if ctx.is_button_down(Button::Right) {
            self.x += 1.0;
        }
    }

    fn draw(&self, gfx: &mut Graphics) {
        gfx.clear(Color::BLACK);
        gfx.rect_fill(self.x, self.y, 8.0, 8.0, Color::WHITE);
    }
}

rico8::game!(MyGame { x: 64.0, y: 64.0 });
```

---
60 fps (or 30, the cart's choice)

---
128 KiB cart · 128 KiB RAM

---
A per-frame work budget

---
Carts can be `#![no_std]`

---
`heapless` for fixed-size collections

---
Tiny by default

---
Projects are real Cargo crates

---
`$EDITOR` + `cargo build` works the same

---
Console hot-reloads the wasm

---
The sandbox: wasmi

---
No WASI. No fs. No network.

---
~26 small ABI functions

---
Fuel metering kills infinite loops

---
A friendly error, not a hang

---
`export game.png`

---
`import` turns it back into a project

---
`export game.html`

---
One self-contained web page

---
Import your PICO-8 carts

---
`rico8 import-pico8 game.p8`

---
Let's see it

---
Ported Airwolf

---
Now let's break something

---
`examples/platformer`

---
Oh BTW!

---
It runs on real handhelds

---
rico8-player

---
PowKiddy running ArkOS

---
Drop the binary, drop your carts, play

---
`Ctrl+R`

---
It rebuilds

---
`saved` → `building…` → `build ok`

---
Show web

---
It's Open Source

---
GPL-3.0

---
Go make a tiny game

---
That's all folks!
<br/>

<https://github.com/zeenix/rico8>
