WASI_SDK_PATH ?= /opt/wasi-sdk
Wolfssl_C_Extra_Flags := -DWOLFSSL_WASM
Wolfssl_C_Extra_Flags += -O3
Wolfssl_Example_C_Files := main.c
Wolfssl_Example_Include_Paths := -I$(WOLFSSL_ROOT)/ \
						 -I$(WOLFSSL_ROOT)/wolfcrypt/

ifndef WOLFSSL_ROOT
$(error WOLFSSL_ROOT is not set. Please set to root wolfssl directory)
endif

WASM_WOLFSSL_LIB ?= $(WOLFSSL_ROOT)/IDE/Wasm

ifeq ($(HAVE_WOLFSSL_TEST), 1)
	Wolfssl_Example_Include_Paths += -I$(WOLFSSL_ROOT)/wolfcrypt/test
	Wolfssl_Example_C_Files += $(WOLFSSL_ROOT)/wolfcrypt/test/test.c
	Wolfssl_C_Extra_Flags += -DHAVE_WOLFSSL_TEST
endif

ifeq ($(HAVE_WOLFSSL_BENCHMARK), 1)
	Wolfssl_Example_C_Files += $(WOLFSSL_ROOT)/wolfcrypt/benchmark/benchmark.c
	Wolfssl_Example_Include_Paths += -I$(WOLFSSL_ROOT)/wolfcrypt/benchmark/
	Wolfssl_C_Extra_Flags += -DHAVE_WOLFSSL_BENCHMARK
endif

ifeq ($(HAVE_WASI_SOCKET), 1)
	WAMR_PATH ?= /opt/wamr
	Wolfssl_Example_C_Files += $(WAMR_PATH)/core/iwasm/libraries/lib-socket/src/wasi/wasi_socket_ext.c
	Wolfssl_Example_C_Files += server-tls.c client-tls.c
	Wolfssl_Example_Include_Paths += -I$(WAMR_PATH)/core/iwasm/libraries/lib-socket/inc -I.
	Wolfssl_C_Extra_Flags += -DHAVE_WASI_SOCKET
endif

ifeq ($(DEBUG), 1)
	Wolfssl_C_Extra_Flags += -DDEBUG -DDEBUG_WOLFSSL
endif

.PHONY: all
all:
	mkdir -p build
	$(WASI_SDK_PATH)/bin/clang \
		--target=wasm32-wasi \
		--sysroot=$(WASI_SDK_PATH)/share/wasi-sysroot/ \
		-Wl,--allow-undefined-file=$(WASI_SDK_PATH)/share/wasi-sysroot/share/wasm32-wasi/defined-symbols.txt \
		-Wl,--strip-all \
		-L $(WASM_WOLFSSL_LIB) -lwolfssl \
		$(Wolfssl_C_Extra_Flags) \
		$(Wolfssl_Example_Include_Paths) \
		-o wolfssl_example.wasm $(Wolfssl_Example_C_Files)

.PHONY: clean
clean:
	rm -rf build