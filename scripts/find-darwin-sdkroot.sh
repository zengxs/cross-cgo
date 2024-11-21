#!/bin/bash
#
# Author: 	Xiangsong Zeng
# Date:		2024-11-21
# Description:
#     This script is used to download the macOS SDK from the
#     internet for provide a way to cross-compile macOS apps
#     on Linux. This is useful for developers who want to
#     build macOS apps on CI servers that run Linux.
#
#     If you are using macOS, this script will find the SDK
#     from the system.

UNAME=$(uname)

if [ "${UNAME}" != "Linux" ] && [ "${UNAME}" != "Darwin" ]; then
    # echo to stderr
    echo "This script is only for Linux and macOS." >&2
    exit 1
fi

# The directory where the macOS SDK will be installed, default
# is "${HOME}/.macosx-sdk/MacOSX.sdk" if not specified.
SDKROOT_INSTALL_DIR="${SDKROOT_INSTALL_DIR:-${HOME}/.macosx-sdk/MacOSX.sdk}"

if [ "${UNAME}" = "Darwin" ]; then
    # If the script is running on macOS, we can find the SDK
    # from the system.
    xcrun --sdk macosx --show-sdk-path
    exit 0
fi

# Typically, this script is designed to run only in a Docker
# environment. This is because most CI environments operate
# within Docker. By default, we do not allow it to run directly
# on the host system. If you want to run it directly on the
# host system, you can set "ALLOW_OUTSIDE_DOCKER=1".
ALLOW_OUTSIDE_DOCKER="${ALLOW_OUTSIDE_DOCKER:-0}"

if [ "${ALLOW_OUTSIDE_DOCKER}" != "1" ]; then
    if [ ! -f /.dockerenv ]; then
        echo "This script is designed to run in a Docker environment." >&2
        echo "If you want to run it directly on the host system, you can set ALLOW_OUTSIDE_DOCKER=1." >&2
        exit 1
    fi
fi

# The default macOS SDK download URL.
DEFAULT_SDK_DOWNLOAD_URL="https://github.com/phracker/MacOSX-SDKs/releases/download/11.3/MacOSX11.3.sdk.tar.xz"
SDK_DOWNLOAD_URL="${SDK_DOWNLOAD_URL:-${DEFAULT_SDK_DOWNLOAD_URL}}"

SDK_DOWNLOAD_FILE="/tmp/MacOSX.sdk.tar.xz"

# If SDKROOT_INSTALL_DIR has existed, we can use it directly.
if [ -d "${SDKROOT_INSTALL_DIR}" ]; then
    echo "${SDKROOT_INSTALL_DIR}"
    exit 0
else
    # Check if xz is available.
    SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
    ${SCRIPT_DIR}/check-xz.sh

    # Download the macOS SDK.
    echo "Downloading the macOS SDK..." >&2
    curl -sSL -o "${SDK_DOWNLOAD_FILE}" "${SDK_DOWNLOAD_URL}"
    mkdir -p "${SDKROOT_INSTALL_DIR}"

    # Extract the macOS SDK.
    tar --strip-components=1 -C "${SDKROOT_INSTALL_DIR}" -xf "${SDK_DOWNLOAD_FILE}"

    # Clean up.
    rm -f "${SDK_DOWNLOAD_FILE}"

    # Print the SDK path.
    echo "${SDKROOT_INSTALL_DIR}"
    exit 0
fi
