SOURCES := $(shell find . -name '*.go')
MAIN_PACKAGE_PATH := .

ZIG := $(CURDIR)/scripts/helpers/zig.sh
ZIG_CC := $(ZIG) cc -w
ZIG_CXX := $(ZIG) c++ -w

LIPO := $(CURDIR)/scripts/helpers/lipo.sh

COMMON_GOFLAGS := -tags 'sqlite_json,sqlite_foreign_keys,sqlite_fts5'

LINUXGNU_GOFLAGS := --ldflags '-linkmode external -w' $(COMMON_GOFLAGS)
LINUXGNU_GLIBC_VERSION := 2.17

LINUXMUSL_GOFLAGS := --ldflags '-linkmode external -w -extldflags -static' $(COMMON_GOFLAGS)

DARWIN_GOFLAGS = --ldflags '-linkmode external -w' $(COMMON_GOFLAGS)
DARWIN_SDKROOT = $(shell bash $(CURDIR)/scripts/find-darwin-sdkroot.sh)
DARWIN_ZIG_FLAGS = \
	-I$(DARWIN_SDKROOT)/usr/include \
	-L$(DARWIN_SDKROOT)/usr/lib \
	-F$(DARWIN_SDKROOT)/System/Library/Frameworks

WINDOWS_GOFLAGS := $(COMMON_GOFLAGS)

# Always use build with cgo enabled
export CGO_ENABLED = 1


.PHONY: all
all: linux macos windows

.PHONY: clean
clean:
	rm -rf dist

.PHONY: linux linuxgnu linuxmusl
linux: linuxgnu linuxmusl
linuxgnu: dist/linuxgnu-amd64/demo dist/linuxgnu-arm64/demo
linuxmusl: dist/linuxmusl-amd64/demo dist/linuxmusl-arm64/demo

dist/linuxgnu-amd64/demo: $(SOURCES)
	$(eval export CC = $(ZIG_CC) --target=x86_64-linux-gnu.$(LINUXGNU_GLIBC_VERSION))
	$(eval export CXX = $(ZIG_CXX) --target=x86_64-linux-gnu.$(LINUXGNU_GLIBC_VERSION))
	$(eval export GOOS = linux)
	$(eval export GOARCH = amd64)
	@echo CC="$(CC)" CXX="$(CXX)" GOOS="$(GOOS)" GOARCH="$(GOARCH)"
	go build $(LINUXGNU_GOFLAGS) -o $@ $(MAIN_PACKAGE_PATH)

dist/linuxgnu-arm64/demo: $(SOURCES)
	$(eval export CC = $(ZIG_CC) --target=aarch64-linux-gnu.$(LINUXGNU_GLIBC_VERSION))
	$(eval export CXX = $(ZIG_CXX) --target=aarch64-linux-gnu.$(LINUXGNU_GLIBC_VERSION))
	$(eval export GOOS = linux)
	$(eval export GOARCH = arm64)
	@echo CC="$(CC)" CXX="$(CXX)" GOOS="$(GOOS)" GOARCH="$(GOARCH)"
	go build $(LINUXGNU_GOFLAGS) -o $@ $(MAIN_PACKAGE_PATH)

dist/linuxmusl-amd64/demo: $(SOURCES)
	$(eval export CC = $(ZIG_CC) --target=x86_64-linux-musl)
	$(eval export CXX = $(ZIG_CXX) --target=x86_64-linux-musl)
	$(eval export GOOS = linux)
	$(eval export GOARCH = amd64)
	@echo CC="$(CC)" CXX="$(CXX)" GOOS="$(GOOS)" GOARCH="$(GOARCH)"
	go build $(LINUXMUSL_GOFLAGS) -o $@ $(MAIN_PACKAGE_PATH)

dist/linuxmusl-arm64/demo: $(SOURCES)
	$(eval export CC = $(ZIG_CC) --target=aarch64-linux-musl)
	$(eval export CXX = $(ZIG_CXX) --target=aarch64-linux-musl)
	$(eval export GOOS = linux)
	$(eval export GOARCH = arm64)
	@echo CC="$(CC)" CXX="$(CXX)" GOOS="$(GOOS)" GOARCH="$(GOARCH)"
	go build $(LINUXMUSL_GOFLAGS) -o $@ $(MAIN_PACKAGE_PATH)

.PHONY: macos
macos: dist/darwin/demo

dist/darwin/demo: dist/darwin-arm64/demo dist/darwin-amd64/demo
	mkdir -p $(dir $@)
	$(LIPO) -output $@ -create $^

dist/darwin-amd64/demo: $(SOURCES)
	$(eval export CC = $(ZIG_CC) --target=x86_64-macos $(DARWIN_ZIG_FLAGS))
	$(eval export CXX = $(ZIG_CXX) --target=x86_64-macos $(DARWIN_ZIG_FLAGS))
	$(eval export GOOS = darwin)
	$(eval export GOARCH = amd64)
	@echo CC="$(CC)" CXX="$(CXX)" GOOS="$(GOOS)" GOARCH="$(GOARCH)"
	go build $(DARWIN_GOFLAGS) -o $@ $(MAIN_PACKAGE_PATH)

dist/darwin-arm64/demo: $(SOURCES)
	$(eval export CC = $(ZIG_CC) --target=aarch64-macos $(DARWIN_ZIG_FLAGS))
	$(eval export CXX = $(ZIG_CXX) --target=aarch64-macos $(DARWIN_ZIG_FLAGS))
	$(eval export GOOS = darwin)
	$(eval export GOARCH = arm64)
	@echo CC="$(CC)" CXX="$(CXX)" GOOS="$(GOOS)" GOARCH="$(GOARCH)"
	go build $(DARWIN_GOFLAGS) -o $@ $(MAIN_PACKAGE_PATH)

.PHONY: windows
windows: dist/windows-amd64/demo.exe dist/windows-arm64/demo.exe dist/windows-386/demo.exe

dist/windows-amd64/demo.exe: $(SOURCES)
	$(eval export CC = $(ZIG_CC) --target=x86_64-windows-gnu)
	$(eval export CXX = $(ZIG_CXX) --target=x86_64-windows-gnu)
	$(eval export GOOS = windows)
	$(eval export GOARCH = amd64)
	@echo CC="$(CC)" CXX="$(CXX)" GOOS="$(GOOS)" GOARCH="$(GOARCH)"
	go build $(WINDOWS_GOFLAGS) -o $@ $(MAIN_PACKAGE_PATH)

dist/windows-arm64/demo.exe: $(SOURCES)
	$(eval export CC = $(ZIG_CC) --target=aarch64-windows-gnu)
	$(eval export CXX = $(ZIG_CXX) --target=aarch64-windows-gnu)
	$(eval export GOOS = windows)
	$(eval export GOARCH = arm64)
	@echo CC="$(CC)" CXX="$(CXX)" GOOS="$(GOOS)" GOARCH="$(GOARCH)"
	go build $(WINDOWS_GOFLAGS) -o $@ $(MAIN_PACKAGE_PATH)

dist/windows-386/demo.exe: $(SOURCES)
	$(eval export CC = $(ZIG_CC) --target=x86-windows-gnu)
	$(eval export CXX = $(ZIG_CXX) --target=x86-windows-gnu)
	$(eval export GOOS = windows)
	$(eval export GOARCH = 386)
	@echo CC="$(CC)" CXX="$(CXX)" GOOS="$(GOOS)" GOARCH="$(GOARCH)"
	go build $(WINDOWS_GOFLAGS) -o $@ $(MAIN_PACKAGE_PATH)
