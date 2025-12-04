#!/bin/bash
# Create symlink from HOME/.pebble-sdk to the pre-installed SDK
# This allows running with --user and custom HOME while still finding the pre-installed SDK
# pebble-tool hardcodes ~/.pebble-sdk and doesn't respect PEBBLE_HOME
if [ -n "$HOME" ] && [ ! -d "$HOME/.pebble-sdk" ]; then
    mkdir -p "$HOME"
    ln -sf /home/pebble/.pebble-sdk "$HOME/.pebble-sdk"
fi

# Ensure the toolchain is in PATH
export PATH="/home/pebble/.pebble-sdk/SDKs/current/toolchain/arm-none-eabi/bin:$PATH"

exec "$@"

