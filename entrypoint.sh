#!/bin/bash
# Set up the pebble SDK environment for the current user
# pebble-tool hardcodes ~/.pebble-sdk and doesn't respect PEBBLE_HOME

if [ -n "$HOME" ] && [ ! -d "$HOME/.pebble-sdk" ]; then
    mkdir -p "$HOME"
    ln -sf /home/pebble/.pebble-sdk "$HOME/.pebble-sdk"
fi

# Ensure the toolchain is in PATH
export PATH="/home/pebble/.pebble-sdk/SDKs/current/toolchain/arm-none-eabi/bin:$PATH"

exec "$@"

