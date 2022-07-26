# WolfSSL for use in WebAssembly Example
Bringing WebAssembly (Wasm) support for WolfSSL with *WebAssembly system interface* (WASI) support for seamless interoperability with the underlying system. This repository provides two examples:

- The example application in `example/`, which support the unit tests, the built-in WolfSSL benchmark and a client/server application for TLS testing.
- A TLS server performance application in `perf/`, which is a performance evaluation tool from WolfSSL for TLS connections.

## Requirements
The Wasm compilation target relies on two external components:

- [WASI-SDK](https://github.com/WebAssembly/wasi-sdk), that provides the compilation toolchain for Wasm. It must be installed at the path `/opt/wasi-sdk`, or given via the variable `WASI_SDK_PATH`.
- Optionally, [WAMR](https://github.com/bytecodealliance/wasm-micro-runtime), that provides a WASI (system interface) extension to fully support socket in case TLS support is needed. It must be installed at the path `/opt/wamr`, or given via the variable `WAMR_PATH`.

WolfSSL environment must have been configured using `./autogen.sh` and the static library for Wasm must have been compiled.
An example of compilation command is given in the WolfSSL repository, in the directory `IDE/Wasm`.

## The example application
```
cd example
make compile_wasm HAVE_WOLFSSL_BENCHMARK=1 HAVE_WOLFSSL_TEST=1 HAVE_WOLFSSL_TLS_SAMPLE=1 WOLFSSL_ROOT=<path>

# Optionally, if WAMR is installed, the Wasm artifact can be compiled AOT afterwards
make compile_aot
```

- To enable wolfssl benchmark tests, specify: `HAVE_WOLFSSL_BENCHMARK` at build
- To enable wolfcrypt testsuite, specify: `HAVE_WOLFSSL_TEST` at build
- To enable a TLS 1.2 sample with a server and a client, specify: `HAVE_WOLFSSL_TLS_SAMPLE` at build

## The TLS server performance application
```
cd perf
make compile_wasm WOLFSSL_ROOT=<path>

# Optionally, if WAMR is installed, the Wasm artifact can be compiled AOT afterwards
make compile_aot
```

### Benchmarking

As Wasm cannot leverage assembly or hardware optimizations, the results of the benchmarks can be compared to the native build with the following flags for a fair comparison:

```
./configure --enable-asm=no --enable-singlethreaded=yes
```

### Limitations
- Single Threaded (multiple threaded applications have not been tested)
- AES-NI use with SGX has not been added in yet
