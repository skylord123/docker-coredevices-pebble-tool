# Docker container for building Pebble watch apps using Core Devices pebble-tool
# https://github.com/coredevices/pebble-tool

FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="Core Devices Pebble Tool"
LABEL org.opencontainers.image.description="Docker container for building Pebble watch apps using the Core Devices pebble-tool"
LABEL org.opencontainers.image.source="https://github.com/skylord123/docker-coredevices-pebble-tool"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    libfdt1 \
    curl \
    git \
    make \
    libfreetype6 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user for building
RUN useradd -m -d /home/pebble -s /bin/bash pebble

# Switch to pebble user
USER pebble
WORKDIR /home/pebble

# Install uv (Python package installer)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Add uv and pebble SDK toolchain to PATH
ENV PATH="/home/pebble/.local/bin:/home/pebble/.pebble-sdk/SDKs/current/toolchain/arm-none-eabi/bin:${PATH}"

# Install pebble-tool (includes all dependencies like pypkjs, sh, etc.)
RUN uv tool install pebble-tool

# Install the latest Pebble SDK
RUN pebble sdk install latest

# Set the working directory for builds
WORKDIR /pebble

# Default command - run pebble build
CMD ["pebble", "build"]

