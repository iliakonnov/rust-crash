# Reproduction
1. Create minimal no_std application. See <https://docs.rust-embedded.org/embedonomicon/smallest-no-std.html> for example
2. Create custom target specification, based on built-in x86_64-unknown-none:
    ```
    rustc +nightly -Z unstable-options --print target-spec-json --target x86_64-unknown-none > x86_64-custom.json
    sed -i 's/"is-builtin": true/"is-builtin": false/' x86_64-custom.json
    ```
3. Notice `"panic-behaviour": "abort"` in this json. **Build succeeds.**
4. Change to `"panic-behaviour": "unwind"`. cargo build will emit enormous error message (see `error.log`)
5. `cargo clean && cargo build` will succeed again.
