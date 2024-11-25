# cross-cgo

This is a simple example of how to cross-compile a Go program that uses CGO.

## Overview

Most of the time, cross-compiling a Go program is as simple as setting the
`GOOS` and `GOARCH` environment variables. However, when you use CGO, things
get a bit more complicated. This is because CGO uses the C compiler and
linker to build the Go program, and these tools are platform-specific.

This example shows how to cross-compile a Go program that uses CGO. It uses
official golang Docker image to build the program for different platforms:

- Linux (glibc/musl) - amd64, arm64
- Windows - amd64, arm64, i386
- macOS - amd64, arm64, universal2

The cross-compilation has been tested on macOS and Linux. It should work on
Windows as well, but I haven't tested it.

The main dependencies is **zig** (as C compiler and linker) and
**MacOSX SDK** (for macOS target). The build script will download and install
these dependencies automatically.

The example program is a simple Go program that uses SQLite via CGO.
You can run the program with the following command:

```bash
# build for all platforms
make all
# run the program (choose the correct binary for your platform, e.g. linux-amd64)
./dist/linux-amd64/demo --database-url sqlite3://./test.sqlite3
```

## Issues

Zig version must be 0.14.0 or later due to this issue: https://github.com/ziglang/zig/issues/20243

Cross-compiling for macOS on other platforms must add `-w` flag to `ldflags` to avoid
DWARF generation error. (`dsymutil` is not available on other platforms).

Error occurs: `error: unable to create compilation: AccessDenied`. Run
`go mod vendor` to keep the dependencies in the project can fix this issue
(I don't know why).

Glibc version: you can specify the glibc version for Linux build by setting
`LINUX_GLIBC_VERSION` in Makefile, default is 2.17 (CentOS 7 compatible).
