#!/usr/bin/env sh

set -e

git checkout cfe093a87fe7450947314f8e05dd9ab5ab829793
cargo clean
cargo build

git apply <<EOF
diff --git a/x86_64-custom.json b/x86_64-custom.json
index 0d33b7d..f0e988c 100644
--- a/x86_64-custom.json
+++ b/x86_64-custom.json
@@ -11,7 +11,7 @@
   "linker-flavor": "ld.lld",
   "llvm-target": "x86_64-unknown-none-elf",
   "max-atomic-width": 64,
-  "panic-strategy": "abort",
+  "panic-strategy": "unwind",
   "position-independent-executables": true,
   "relro-level": "full",
   "stack-probes": {
EOF

RUST_BACKTRACE=full cargo build -v

