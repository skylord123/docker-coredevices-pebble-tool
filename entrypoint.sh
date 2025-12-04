#!/bin/bash
# Create symlink from HOME/.pebble-sdk to /opt/pebble-sdk
# This allows running with --user and custom HOME while still finding the pre-installed SDK
if [ -n "$HOME" ] && [ ! -d "$HOME/.pebble-sdk" ]; then
    mkdir -p "$HOME"
    ln -sf /opt/pebble-sdk "$HOME/.pebble-sdk"
fi

# Also ensure the toolchain is in PATH
export PATH="/opt/pebble-sdk/SDKs/current/toolchain/arm-none-eabi/bin:$PATH"

exec "$@"

