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

# Create a non-root user for installation
RUN useradd -m -d /home/pebble -s /bin/bash pebble

# Switch to pebble user for installation
USER pebble
WORKDIR /home/pebble

# Install uv (Python package installer)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Add uv to PATH
ENV PATH="/home/pebble/.local/bin:${PATH}"

# Install pebble-tool (includes all dependencies like pypkjs, sh, etc.)
RUN uv tool install pebble-tool

# Install the latest Pebble SDK
RUN pebble sdk install latest

# Make the SDK and tools accessible by all users
# This allows running with --user flag for CI environments
USER root
RUN chmod -R a+rwX /home/pebble/.pebble-sdk && \
    chmod -R a+rX /home/pebble/.local

# Add entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch back to pebble user as default
USER pebble

# Set the working directory for builds
WORKDIR /pebble

ENTRYPOINT ["/entrypoint.sh"]
CMD ["pebble", "build"]

