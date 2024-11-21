#!/bin/bash

set -e

# Find zig from system PATH.
if command -v zig > /dev/null; then
    zig $@
    exit $?
fi

ALLOW_OUTSIDE_DOCKER="${ALLOW_OUTSIDE_DOCKER:-0}"

if [ "$(uname)" != "Linux" ]; then
    echo "This zig.sh script is only for Linux." >&2
    exit 1
fi

if [ "${ALLOW_OUTSIDE_DOCKER}" != "1" ]; then
    if [ ! -f /.dockerenv ]; then
        echo "This zig.sh script is designed to run in a Docker environment." >&2
        echo "You should install Zig by yourself on the host system." >&2
        echo "If you want to run zig.sh with automatic installation on the host system, you can set ALLOW_OUTSIDE_DOCKER=1." >&2
        exit 1
    fi
fi

ZIG_DIR="${ZIG_DIR:-${HOME}/.zig}"

# Download and install Zig.

if [ ! -x "${ZIG_DIR}/zig" ]; then
    # https://github.com/ziglang/zig/issues/20243
    ZIG_VERSION="${ZIG_VERSION:-0.14.0-dev.2265+8a00bd4ce}"

    ARCH=$(uname -m)
    # is development version (contains 'dev')?
    if echo "${ZIG_VERSION}" | grep -q 'dev'; then
        ZIG_DOWNLOAD_URL="https://ziglang.org/builds/zig-linux-${ARCH}-${ZIG_VERSION}.tar.xz"
    else
        ZIG_DOWNLOAD_URL="https://ziglang.org/download/${ZIG_VERSION}/zig-linux-${ARCH}-${ZIG_VERSION}.tar.xz"
    fi
    DOWNLOAD_FILE="/tmp/zig.tar.xz"

    # Check if xz is available.
    SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
    ${SCRIPT_DIR}/../check-xz.sh

    echo "Downloading Zig from ${ZIG_DOWNLOAD_URL}..." >&2
    curl -sSL -o "${DOWNLOAD_FILE}" "${ZIG_DOWNLOAD_URL}"
    mkdir -p "${ZIG_DIR}"
    tar --strip-components=1 -C "${ZIG_DIR}" -xf "${DOWNLOAD_FILE}"
    echo "Zig has been installed to ${ZIG_DIR}." >&2
    rm -f "${DOWNLOAD_FILE}"
fi

${ZIG_DIR}/zig $@
