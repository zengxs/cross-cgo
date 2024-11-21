SOURCES := $(shell find . -name '*.go')
MAIN_PACKAGE_PATH := .

ZIG := $(CURDIR)/scripts/helpers/zig.sh
ZIG_CC := $(ZIG) cc -w
ZIG_CXX := $(ZIG) c++ -w

LIPO := $(CURDIR)/scripts/helpers/lipo.sh

LINUX_GOFLAGS := --ldflags '-linkmode external -w' -tags 'sqlite_json,sqlite_foreign_keys,sqlite_fts5'
LINUX_GLIBC_VERSION := 2.17

DARWIN_GOFLAGS = --ldflags '-linkmode external -w' -tags 'sqlite_json,sqlite_foreign_keys,sqlite_fts5'
DARWIN_SDKROOT = $(shell bash $(CURDIR)/scripts/find-darwin-sdkroot.sh)
DARWIN_ZIG_FLAGS = \
	-I$(DARWIN_SDKROOT)/usr/include \
	-L$(DARWIN_SDKROOT)/usr/lib \
	-F$(DARWIN_SDKROOT)/System/Library/Frameworks

WINDOWS_GOFLAGS := -tags 'sqlite_json,sqlite_foreign_keys,sqlite_fts5'

# Always use build with cgo enabled
export CGO_ENABLED = 1


.PHONY: all
all: linux macos windows

.PHONY: clean
clean:
	rm -rf dist

.PHONY: linux
linux: dist/linux-amd64/demo dist/linux-arm64/demo

dist/linux-amd64/demo: $(SOURCES)
	$(eval export CC = $(ZIG_CC) --target=x86_64-linux-gnu.$(LINUX_GLIBC_VERSION))
	$(eval export CXX = $(ZIG_CXX) --target=x86_64-linux-gnu.$(LINUX_GLIBC_VERSION))
	$(eval export GOOS = linux)
	$(eval export GOARCH = amd64)
	@echo CC="$(CC)" CXX="$(CXX)" GOOS="$(GOOS)" GOARCH="$(GOARCH)"
	go build $(LINUX_GOFLAGS) -o $@ $(MAIN_PACKAGE_PATH)

dist/linux-arm64/demo: $(SOURCES)
	$(eval export CC = $(ZIG_CC) --target=aarch64-linux-gnu.$(LINUX_GLIBC_VERSION))
	$(eval export CXX = $(ZIG_CXX) --target=aarch64-linux-gnu.$(LINUX_GLIBC_VERSION))
	$(eval export GOOS = linux)
	$(eval export GOARCH = arm64)
	@echo CC="$(CC)" CXX="$(CXX)" GOOS="$(GOOS)" GOARCH="$(GOARCH)"
	go build $(LINUX_GOFLAGS) -o $@ $(MAIN_PACKAGE_PATH)

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
windows: dist/windows-amd64/demo.exe dist/windows-arm64/demo.exe

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
