# Description
This small project gives SIGTRAP in rustc when compiled. Looks like for some reason LLVM does not handle `+sse2` well in target specification.

# Target file
1. Using x86_64-unknown-none as template
```
$ rustc +nightly -Z unstable-options --print target-spec-json --target x86_64-unknown-none > x86_64-custom.json
```
2. Change `-sse,-sse2` to `+sse,+sse2`
```diff
$ diff x86_64-unknown-none.json x86_64-custom.json
8,9c8
<   "features": "-mmx,-sse,-sse2,-sse3,-ssse3,-sse4.1,-sse4.2,-3dnow,-3dnowa,-avx,-avx2,+soft-float",
<   "is-builtin": true,
---
>   "features": "-mmx,+sse,+sse2,-sse3,-ssse3,-sse4.1,-sse4.2,-3dnow,-3dnowa,-avx,-avx2,+soft-float",
```

Note: just `-sse,+sse2` will give SIGTRAP too, but this configuration have no sence since SSE2 can't exist without SSE.

# Building
```
$ cargo build
...
   Compiling compiler_builtins v0.1.66
error: could not compile `compiler_builtins`

Caused by:
  process didn't exit successfully: `rustc --crate-name compiler_builtins ~/.cargo/registry/src/github.com-1ecc6299db9ec823/compiler_builtins-0.1.66/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,future-incompat --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg 'feature="compiler-builtins"' --cfg 'feature="core"' --cfg 'feature="default"' --cfg 'feature="mem"' --cfg 'feature="rustc-dep-of-std"' -C metadata=87b7f5e35c5dfb1a -C extra-filename=-87b7f5e35c5dfb1a --out-dir ~/minimal/target/x86_64-custom/debug/deps --target ~/minimal/x86_64-custom.json -Z force-unstable-if-unmarked -L dependency=~/minimal/target/x86_64-custom/debug/deps -L dependency=~/minimal/target/debug/deps --extern core=~/minimal/target/x86_64-custom/debug/deps/librustc_std_workspace_core-65e9596df1fda648.rmeta --cap-lints allow --cfg 'feature="unstable"' --cfg 'feature="mem-unaligned"'` (signal: 5, SIGTRAP: trace/breakpoint trap)
...
```

# Rust version
```
$ rustc --version --verbose
rustc 1.59.0-nightly (f8abed9ed 2021-12-26)
binary: rustc
commit-hash: f8abed9ed48bace6be0087bcd44ed534e239b8d8
commit-date: 2021-12-26
host: x86_64-unknown-linux-gnu
release: 1.59.0-nightly
LLVM version: 13.0.0
```

# GDB backtrace
```
Note:
$ rust-gdb --args rustc …
(gdb) r
Thread 18 "opt compiler_bu" received signal SIGTRAP, Trace/breakpoint trap.
[Switching to Thread 0x7fffdf9ff640 (LWP 128256)]
0x00007ffff1bfbf78 in ?? () from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/../lib/libLLVM-13-rust-1.59.0-nightly.so

(gdb) bt
#0  0x00007ffff1bfbf78 in ?? () from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/../lib/libLLVM-13-rust-1.59.0-nightly.so
#1  0x00007ffff180c288 in foldCONCAT_VECTORS(llvm::SDLoc const&, llvm::EVT, llvm::ArrayRef<llvm::SDValue>, llvm::SelectionDAG&) [clone .llvm.9555667491127074190] ()
   from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/../lib/libLLVM-13-rust-1.59.0-nightly.so
#2  0x00007ffff1809525 in llvm::SelectionDAG::getNode(unsigned int, llvm::SDLoc const&, llvm::EVT, llvm::SDValue, llvm::SDValue, llvm::SDNodeFlags) ()
   from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/../lib/libLLVM-13-rust-1.59.0-nightly.so
#3  0x00007ffff3596b13 in LowerCVTPS2PH(llvm::SDValue, llvm::SelectionDAG&) ()
   from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/../lib/libLLVM-13-rust-1.59.0-nightly.so
#4  0x00007ffff2521838 in llvm::TargetLowering::LowerOperationWrapper(llvm::SDNode*, llvm::SmallVectorImpl<llvm::SDValue>&, llvm::SelectionDAG&) const ()
   from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/../lib/libLLVM-13-rust-1.59.0-nightly.so
#5  0x00007ffff2086eca in llvm::DAGTypeLegalizer::SplitVectorOperand(llvm::SDNode*, unsigned int) ()
   from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/../lib/libLLVM-13-rust-1.59.0-nightly.so
#6  0x00007ffff16f5ea1 in llvm::DAGTypeLegalizer::run() () from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/../lib/libLLVM-13-rust-1.59.0-nightly.so
#7  0x00007ffff16f038c in llvm::SelectionDAG::LegalizeTypes() ()
   from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/../lib/libLLVM-13-rust-1.59.0-nightly.so
#8  0x00007ffff16ee6e0 in llvm::SelectionDAGISel::CodeGenAndEmitDAG() ()
   from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/../lib/libLLVM-13-rust-1.59.0-nightly.so
#9  0x00007ffff16d0552 in llvm::SelectionDAGISel::SelectAllBasicBlocks(llvm::Function const&) ()
   from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/../lib/libLLVM-13-rust-1.59.0-nightly.so
#10 0x00007ffff16c9b8d in llvm::SelectionDAGISel::runOnMachineFunction(llvm::MachineFunction&) ()
   from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/../lib/libLLVM-13-rust-1.59.0-nightly.so
#11 0x00007ffff16c9688 in (anonymous namespace)::X86DAGToDAGISel::runOnMachineFunction(llvm::MachineFunction&) [clone .llvm.9579652157589533625] ()
   from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/../lib/libLLVM-13-rust-1.59.0-nightly.so
#12 0x00007ffff1cb94fa in llvm::MachineFunctionPass::runOnFunction(llvm::Function&) ()
   from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/../lib/libLLVM-13-rust-1.59.0-nightly.so
#13 0x00007ffff1b70447 in llvm::FPPassManager::runOnFunction(llvm::Function&) ()
   from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/../lib/libLLVM-13-rust-1.59.0-nightly.so
#14 0x00007ffff1b6fd5f in llvm::FPPassManager::runOnModule(llvm::Module&) ()
   from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/../lib/libLLVM-13-rust-1.59.0-nightly.so
#15 0x00007ffff1fa1fb9 in llvm::legacy::PassManagerImpl::run(llvm::Module&) ()
   from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/../lib/libLLVM-13-rust-1.59.0-nightly.so
#16 0x00007ffff6653514 in LLVMRustWriteOutputFile () from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/librustc_driver-86b6ef79da72f228.so
#17 0x00007ffff6648557 in rustc_codegen_llvm::back::write::write_output_file ()
   from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/librustc_driver-86b6ef79da72f228.so
#18 0x00007ffff664b3d6 in rustc_codegen_llvm::back::write::codegen ()
   from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/librustc_driver-86b6ef79da72f228.so
#19 0x00007ffff65e123b in rustc_codegen_ssa::back::write::finish_intra_module_work::<rustc_codegen_llvm::LlvmCodegenBackend> ()
   from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/librustc_driver-86b6ef79da72f228.so
#20 0x00007ffff65e049b in rustc_codegen_ssa::back::write::execute_work_item::<rustc_codegen_llvm::LlvmCodegenBackend> ()
   from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/librustc_driver-86b6ef79da72f228.so
#21 0x00007ffff663010f in std::sys_common::backtrace::__rust_begin_short_backtrace::<<rustc_codegen_llvm::LlvmCodegenBackend as rustc_codegen_ssa::traits::backend::ExtraBackendMethods>::spawn_named_thread<rustc_codegen_ssa::back::write::spawn_work<rustc_codegen_llvm::LlvmCodegenBackend>::{closure#0}, ()>::{closure#0}, ()> ()
   from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/librustc_driver-86b6ef79da72f228.so
#22 0x00007ffff663b7e3 in <<std::thread::Builder>::spawn_unchecked<<rustc_codegen_llvm::LlvmCodegenBackend as rustc_codegen_ssa::traits::backend::ExtraBackendMethods>::spawn_named_thread<rustc_codegen_ssa::back::write::spawn_work<rustc_codegen_llvm::LlvmCodegenBackend>::{closure#0}, ()>::{closure#0}, ()>::{closure#1} as core::ops::function::FnOnce<()>>::call_once::{shim:vtable#0} () from ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/../lib/librustc_driver-86b6ef79da72f228.so
#23 0x00007ffff3fa9da3 in alloc::boxed::{impl#44}::call_once<(), dyn core::ops::function::FnOnce<(), Output=()>, alloc::alloc::Global> ()
    at /rustc/51e8031e14a899477a5e2d78ce461cab31123354/library/alloc/src/boxed.rs:1811
#24 alloc::boxed::{impl#44}::call_once<(), alloc::boxed::Box<dyn core::ops::function::FnOnce<(), Output=()>, alloc::alloc::Global>, alloc::alloc::Global> ()
    at /rustc/51e8031e14a899477a5e2d78ce461cab31123354/library/alloc/src/boxed.rs:1811
#25 std::sys::unix::thread::{impl#2}::new::thread_start () at library/std/src/sys/unix/thread.rs:108
#26 0x00007ffff3ea9259 in start_thread () from /usr/lib/libpthread.so.0
#27 0x00007ffff3dc75e3 in clone () from /usr/lib/libc.so.6
```
Note: backtrace taken on earlier version: `rustc 1.59.0-nightly (51e8031e1 2021-12-25)`, but on newer version error is same.

