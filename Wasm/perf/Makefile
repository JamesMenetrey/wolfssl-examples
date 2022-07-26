Server_Tls_Perf_Wasm_Name = server-tls-poll-perf.wasm
Server_Tls_Perf_Aot_Name = server-tls-poll-perf.aot
Server_Tls_Perf_C_Files = server-tls-poll-perf.c
HAVE_WASI_SOCKET = 1

include ../wasm_common.mk

.PHONY: all
all: compile_wasm compile_aot

.PHONY: compile_wasm
compile_wasm:
	$(call compile_wasm,$(Server_Tls_Perf_Wasm_Name),$(Server_Tls_Perf_C_Files))

.PHONY: compile_aot
compile_aot:
	$(call compile_aot,$(Server_Tls_Perf_Aot_Name),$(Server_Tls_Perf_Wasm_Name))

.PHONY: clean
clean:
	$(call clean_wasm,$(Server_Tls_Perf_Wasm_Name))