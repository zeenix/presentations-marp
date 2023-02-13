#![doc(test(attr(
    allow(unused),
    deny(warnings),
    // W/o this, we seem to get some bogus warning about `extern crate zbus`.
    allow(unused_extern_crates),
)))]

#[cfg(doctest)]
mod doctests {
    doc_comment::doctest!("../01-dipping-toes.md");
}
