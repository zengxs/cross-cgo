#!/bin/bash

set -e

if command -v xz > /dev/null; then
    exit 0
fi

echo "xz is required but not found in PATH." >&2

if command -v apt-get > /dev/null; then
    # install xz from if is ubuntu or debian
    if command -v apt-get > /dev/null; then
        echo "Installing xz-utils using apt-get..." >&2
        # Is root user?
        if [ "$(id -u)" -ne 0 ]; then
            APT_GET="sudo apt-get"
        else
            APT_GET="apt-get"
        fi
        $APT_GET update -yq
        $APT_GET install -yq xz-utils
        exit $?
    else
        echo "xz is required to extract the Zig archive." >&2
        exit 1
    fi
else
    echo "xz is not found in PATH and package manager is not available." >&2
    exit 1
fi
