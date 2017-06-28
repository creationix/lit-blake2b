LUAJIT_OS=$(shell luajit -e "print(require('ffi').os)")
LUAJIT_ARCH=$(shell luajit -e "print(require('ffi').arch)")
TARGET_DIR=$(LUAJIT_OS)-$(LUAJIT_ARCH)/

ifeq ($(LUAJIT_OS), OSX)
BLAKE2_LIB=libblake2.dylib
else
BLAKE2_LIB=libblake2.so
endif

libs: build
	cmake --build build --config Release
	mkdir -p $(TARGET_DIR)
	cp build/$(BLAKE2_LIB) $(TARGET_DIR)

BLAKE2/ref:
	git submodule update --init BLAKE2

build: BLAKE2/ref
	cmake -Bbuild -H. -GNinja

blake2-sample/main.lua:
	git submodule update --init blake2-sample

blake2-sample/deps: blake2-sample/main.lua
	cd blake2-sample && lit install
	rm -rf blake2-sample/deps/blake2
	ln -s ../.. blake2-sample/deps/blake2

test: libs blake2-sample/deps
	luvi blake2-sample

clean:
	rm -rf build blake2-sample/deps
