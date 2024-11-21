#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    # use lipo from a macOS system
    xcrun lipo $@
    exit $?
elif command -v go > /dev/null; then
    # unset GOOS and GOARCH to use the host system's architecture
    GOOS="" GOARCH="" go run github.com/konoui/lipo@latest $@
    exit $?
else
    echo "Please run this script on a macOS system or Go toolchain is installed."
    exit 1
fi
