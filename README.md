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

docker-build:
	docker run --rm -v $(shell pwd):/pebble $(DOCKER_IMAGE)

docker-clean:
	docker run --rm -v $(shell pwd):/pebble $(DOCKER_IMAGE) pebble clean
```

## Usage in GitHub Actions

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/skylord123/docker-coredevices-pebble-tool:latest
    steps:
      - uses: actions/checkout@v4
      - name: Build Pebble app
        run: pebble build
      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: pebble-app
          path: build/*.pbw
```

## Building the Image Locally

```bash
git clone https://github.com/skylord123/docker-coredevices-pebble-tool.git
cd docker-coredevices-pebble-tool
docker build -t pebble-tool .
```

## Image Tags

- `latest` - Latest build from the main branch
- `vX.Y.Z` - Semantic version releases
- `YYYYMMDD` - Weekly scheduled builds (Sundays)
- `<sha>` - Specific commit builds

## License

MIT License - See [LICENSE](LICENSE) for details.
