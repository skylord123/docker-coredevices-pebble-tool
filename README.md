# docker-coredevices-pebble-tool

Docker container for building Pebble watch apps using the [Core Devices pebble-tool](https://github.com/coredevices/pebble-tool).

## Overview

This container provides a ready-to-use build environment for Pebble smartwatch applications. It includes:

- Debian Bookworm slim base (minimal footprint with glibc compatibility)
- Python 3 with pebble-tool installed via [uv](https://github.com/astral-sh/uv)
- Latest Pebble SDK pre-installed (including ARM cross-compiler toolchain)
- Node.js and npm for JavaScript/Rocky.js apps
- Common build tools (make, git)

## Quick Start

### Pull the image

```bash
docker pull ghcr.io/skylord123/docker-coredevices-pebble-tool:latest
```

### Build a Pebble app

Navigate to your Pebble project directory and run:

```bash
docker run --rm -v $(pwd):/pebble ghcr.io/skylord123/docker-coredevices-pebble-tool:latest
```

This will run `pebble build` by default and output the `.pbw` file to your `build/` directory.

### Run custom pebble commands

```bash
# Check pebble version
docker run --rm ghcr.io/skylord123/docker-coredevices-pebble-tool:latest pebble --version

# List installed SDKs
docker run --rm ghcr.io/skylord123/docker-coredevices-pebble-tool:latest pebble sdk list

# Run make instead of pebble build
docker run --rm -v $(pwd):/pebble ghcr.io/skylord123/docker-coredevices-pebble-tool:latest make
```

## Usage in Makefile

You can add a target to your project's Makefile for easy Docker builds:

```makefile
DOCKER_IMAGE = ghcr.io/skylord123/docker-coredevices-pebble-tool:latest
DOCKER_RUN = docker run --rm -v $(shell pwd):/pebble \
	--user $(shell id -u):$(shell id -g) \
	-e HOME=/tmp \
	$(DOCKER_IMAGE)

docker-build:
	$(DOCKER_RUN)

docker-clean:
	$(DOCKER_RUN) pebble clean

# Interactive shell for development
docker:
	docker run --rm -it -v $(shell pwd):/pebble $(DOCKER_IMAGE) /bin/bash
```

The `--user` flag ensures files created in the build directory are owned by your user, and `-e HOME=/tmp` provides a writable home directory for pebble-tool's settings.

## Usage in GitHub Actions

```yaml
name: Build Pebble app

on:
  push:
    branches: ['**']
  pull_request:
    branches: ['**']

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build with Docker
        run: make docker-build
      
      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: pebble-app
          path: build/*.pbw
```

This assumes you have a `Makefile` with the `docker-build` target shown above.

## Building the Image Locally

```bash
git clone https://github.com/skylord123/docker-coredevices-pebble-tool.git
cd docker-coredevices-pebble-tool
docker build -t pebble-tool .
```

## License

MIT License - See [LICENSE](LICENSE) for details.
