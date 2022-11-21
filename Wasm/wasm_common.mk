WASI_SDK_PATH ?= /opt/wasi-sdk
BUILD_DIR ?= build
Wolfssl_C_Extra_Flags := -DWOLFSSL_WASM
Wolfssl_C_Extra_Flags += -O3
# Keep these flags in sync with the ones present in the wasm_static.mk file in the WolfSSL repo.
Wolfssl_C_Extra_Flags +=  -DWOLFSSL_AES_DIRECT -DHAVE_AES_KEYWRAP -DHAVE_CAMELLIA -DWOLFSSL_SHA224 -DWOLFSSL_SHA512 -DWOLFSSL_SHA384 -DHAVE_HKDF -DTFM_ECC256 -DECC_SHAMIR \
	 						-DWC_RSA_PSS -DWOLFSSL_DH_EXTRA -DWOLFSSL_BASE64_ENCODE -DWOLFSSL_SHA3 -DHAVE_POLY1305 -DHAVE_ONE_TIME_AUTH \
							-DHAVE_CHACHA -DHAVE_HASHDRBG -DHAVE_OPENSSL_CMD -DHAVE_CRL -DHAVE_TLS_EXTENSIONS -DHAVE_SUPPORTED_CURVES \
							-DHAVE_FFDHE_2048 -DHAVE_SUPPORTED_CURVES -DFP_MAX_BITS=8192 -DWOLFSSL_ALT_CERT_CHAINS \
							-DWOLFSSL_TLS13 -DWOLFSSL_POST_HANDSHAKE_AUTH -DWOLFSSL_SEND_HRR_COOKIE -DWOLFSSL_HKDF -DWC_RSA_PSS -DWOLFSSL_AESGCM -DWOLFSSL_ECC -DWOLFSSL_CURVE25519 -DWOLFSSL_ED25519 \
							-DWOLFSSL_CURVE448 -DWOLFSSL_ED448
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

# compile_wasm,<output_file>,<source_files>[,include_paths][,compiler_flags]
define compile_wasm
	mkdir -p $(BUILD_DIR)
	$(WASI_SDK_PATH)/bin/clang \
		--target=wasm32-wasi \
		--sysroot=$(WASI_SDK_PATH)/share/wasi-sysroot/ \
		-Wl,--allow-undefined-file=$(WASI_SDK_PATH)/share/wasi-sysroot/share/wasm32-wasi/defined-symbols.txt \
		-Wl,--strip-all \
		-L $(WASM_WOLFSSL_LIB) -lwolfssl \
		$(Wolfssl_C_Extra_Flags) $(4) \
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
