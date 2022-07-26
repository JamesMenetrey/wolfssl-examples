WASI_SDK_PATH ?= /opt/wasi-sdk
BUILD_DIR ?= build
Wolfssl_C_Extra_Flags := -DWOLFSSL_WASM
Wolfssl_C_Extra_Flags += -O3
Wolfssl_C_Include_Paths := -I$(WOLFSSL_ROOT) \
						 -I$(WOLFSSL_ROOT)/wolfcrypt
WASM_WOLFSSL_LIB ?= $(WOLFSSL_ROOT)/IDE/Wasm

ifndef WOLFSSL_ROOT
$(error WOLFSSL_ROOT is not set. Please set to root wolfssl directory)
endif

ifeq ($(HAVE_WASI_SOCKET), 1)
# Add the support for the socket thanks to the socket extension of WAMR,
# since this is not yet fully supported by WASI.
WAMR_PATH ?= /opt/wamr
Wolfssl_C_Files += $(WAMR_PATH)/core/iwasm/libraries/lib-socket/src/wasi/wasi_socket_ext.c
Wolfssl_C_Include_Paths += -I$(WAMR_PATH)/core/iwasm/libraries/lib-socket/inc
Wolfssl_C_Extra_Flags += -DHAVE_WASI_SOCKET
endif

ifeq ($(DEBUG), 1)
Wolfssl_C_Extra_Flags += -DDEBUG -DDEBUG_WOLFSSL
endif

# compile_wasm,<output_file>,<source_files>[,include_paths]
define compile_wasm
	mkdir -p $(BUILD_DIR)
	$(WASI_SDK_PATH)/bin/clang \
		--target=wasm32-wasi \
		--sysroot=$(WASI_SDK_PATH)/share/wasi-sysroot/ \
		-Wl,--allow-undefined-file=$(WASI_SDK_PATH)/share/wasi-sysroot/share/wasm32-wasi/defined-symbols.txt \
		-Wl,--strip-all \
		-L $(WASM_WOLFSSL_LIB) -lwolfssl \
		$(Wolfssl_C_Extra_Flags) \
		$(Wolfssl_C_Include_Paths) $(3) \
		-o $(BUILD_DIR)/$(1) $(Wolfssl_C_Files) $(2)
endef

# compile_aot,<output_aot>,<input_wasm>
define compile_aot
	$(WAMR_PATH)/wamr-compiler/build/wamrc \
		$(AOTFLAGS) \
		-o $(BUILD_DIR)/$(1) $(BUILD_DIR)/$(2)
endef

# clean_wasm,<output_file>
define clean_wasm
	rm -f $(1)
endef
