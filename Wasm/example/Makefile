Wolfssl_Example_Wasm_Name = wasm_example.wasm
Wolfssl_Example_Aot_Name = wasm_example.aot
Wolfssl_Example_C_Files = main.c
Wolfssl_Example_Include_Paths = -I.

ifeq ($(HAVE_WOLFSSL_TEST), 1)
Wolfssl_Example_Include_Paths += -I$(WOLFSSL_ROOT)/wolfcrypt/test
Wolfssl_Example_C_Files += $(WOLFSSL_ROOT)/wolfcrypt/test/test.c
Wolfssl_Example_C_Extra_Flags += -DHAVE_WOLFSSL_TEST
endif

ifeq ($(HAVE_WOLFSSL_BENCHMARK), 1)
Wolfssl_Example_C_Files += $(WOLFSSL_ROOT)/wolfcrypt/benchmark/benchmark.c
Wolfssl_Example_Include_Paths += -I$(WOLFSSL_ROOT)/wolfcrypt/benchmark/
Wolfssl_Example_C_Extra_Flags += -DHAVE_WOLFSSL_BENCHMARK
endif

ifeq ($(HAVE_WOLFSSL_TLS_SAMPLE), 1)
HAVE_WASI_SOCKET = 1
Wolfssl_Example_C_Files += server-tls.c client-tls.c
endif

include ../wasm_common.mk

.PHONY: all
all: compile_wasm compile_aot

.PHONY: compile_wasm
compile_wasm:
	$(call compile_wasm,$(Wolfssl_Example_Wasm_Name),$(Wolfssl_Example_C_Files),$(Wolfssl_Example_Include_Paths),$(Wolfssl_Example_C_Extra_Flags))

.PHONY: compile_aot
compile_aot:
	$(call compile_aot,$(Wolfssl_Example_Aot_Name),$(Wolfssl_Example_Wasm_Name))

.PHONY: clean
clean:
	$(call clean_wasm,$(Wolfssl_Example_Wasm_Name))