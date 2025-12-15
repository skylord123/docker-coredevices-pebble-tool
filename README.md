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

You can add targets to your project's Makefile to easily build your Pebble app using Docker without needing to install the Pebble SDK on your system:

```makefile
DOCKER_IMAGE = ghcr.io/skylord123/docker-coredevices-pebble-tool:latest
DOCKER_RUN = docker run --rm -v $(shell pwd):/pebble \
	--user $(shell id -u):$(shell id -g) \
	-e HOME=/tmp \
	$(DOCKER_IMAGE)

# Build your app using Docker (no local SDK needed!)
docker-build:
	$(DOCKER_RUN)

# Clean build artifacts
docker-clean:
	$(DOCKER_RUN) pebble clean

# Interactive shell for development/debugging
docker-shell:
	docker run --rm -it -v $(shell pwd):/pebble $(DOCKER_IMAGE) /bin/bash

# Install/update the Pebble SDK in the container
docker-sdk-install:
	$(DOCKER_RUN) pebble sdk install latest

# List available SDK versions
docker-sdk-list:
	$(DOCKER_RUN) pebble sdk list
```

**Building your app from your PC:**

Instead of installing the Pebble SDK locally, just run:
```bash
make docker-build
```

Your built `.pbw` file will appear in the `build/` directory, owned by your user (not root).

**How it works:**
- The `--user` flag ensures files created in the build directory match your user ID, so you can edit and manage them normally
- `-e HOME=/tmp` provides a writable home directory for pebble-tool's temporary files and settings
- The `-v $(shell pwd):/pebble` mount makes your current project directory available inside the container
- Everything runs in an isolated container with all dependencies pre-installed

This approach means you can build Pebble apps on any machine with Docker installed, without needing to set up the SDK, Python environment, or ARM toolchain.

## Usage in GitHub Actions

This container is designed to work seamlessly with GitHub Actions for automated builds and releases.

### Continuous Build Workflow

Create `.github/workflows/build.yml` to automatically build your Pebble app on every push or pull request:

```yaml
name: Build Pebble app

on:
  # Triggers the workflow on push or pull request events for all branches
  push:
    branches: ['**']
  pull_request:
    branches: ['**']

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Set short git commit SHA
        id: vars
        run: |
          calculatedSha=$(git rev-parse --short ${{ github.sha }})
          echo "COMMIT_SHORT_SHA=$calculatedSha" >> $GITHUB_ENV

      - name: Build with Docker
        run: make docker-build

      - name: Rename app
        run: cp build/pebble.pbw pebble-home-assistant-ws-g${{ env.COMMIT_SHORT_SHA }}.pbw

      - name: Generate ELF bundle
        run: |
          mkdir elfs
          cp build/basalt/pebble-app.elf elfs/pebble-app-basalt.elf
          cp build/diorite/pebble-app.elf elfs/pebble-app-diorite.elf
          cp build/chalk/pebble-app.elf elfs/pebble-app-chalk.elf
          cp build/aplite/pebble-app.elf elfs/pebble-app-aplite.elf
          cp build/emery/pebble-app.elf elfs/pebble-app-emery.elf
          zip -r elfs.zip elfs

      - name: Upload PBW
        uses: actions/upload-artifact@v4
        with:
          name: pebble-home-assistant-ws PBW
          path: pebble-home-assistant-ws-g${{ env.COMMIT_SHORT_SHA }}.pbw
          if-no-files-found: error

      - name: Upload ELFs
        uses: actions/upload-artifact@v4
        with:
          name: Debug ELFs
          path: elfs.zip
```

**What this does:**
- Triggers on every push or pull request to any branch
- Builds your Pebble app using the Docker container
- Renames the built `.pbw` file to include the git commit SHA for easy identification
- Bundles all platform-specific ELF files for debugging purposes
- Uploads both the PBW and ELF bundle as artifacts to the workflow run

**Note:** GitHub automatically deletes workflow artifacts after 90 days (default retention period). For permanent builds, use the release workflow below.

### Release Workflow

Create `.github/workflows/release.yml` to automatically build and attach your app to GitHub releases:

```yaml
name: Release

on:
  push:
    tags:
      - 'v*.*'

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Build the app
        run: make docker-build

      - name: Upload PBW Artifact
        uses: actions/upload-artifact@v4
        with:
          name: pebble-home-assistant-ws
          path: build/*.pbw

      - name: Create Release
        uses: softprops/action-gh-release@v2
        with:
          generate_release_notes: true
          files: build/*.pbw
```

**What this does:**
- Triggers when you push a version tag (e.g., `v1.0`, `v2.1.3`)
- Builds your Pebble app using the Docker container
- Creates a new GitHub release if one doesn't exist for the tag (with auto-generated release notes)
- Updates an existing release if you've already created one manually
- Attaches the built `.pbw` file directly to the release for permanent storage

**Usage options:**

*Option 1: Create release from tag (automatic)*
```bash
git tag v1.0.0
git push origin v1.0.0
```
The workflow will automatically create the release with generated notes and attach the built file.

*Option 2: Create release manually first (manual control)*
1. Create a release in GitHub UI with your custom description
2. Push a tag matching the release version
3. The workflow will build and attach the `.pbw` file to your existing release

This workflow ensures your releases have permanent download links that don't expire like workflow artifacts do.

Both workflows assume you have a `Makefile` with the `docker-build` target shown above.

## Building the Image Locally

```bash
git clone https://github.com/skylord123/docker-coredevices-pebble-tool.git
cd docker-coredevices-pebble-tool
docker build -t pebble-tool .
```

## License

MIT License - See [LICENSE](LICENSE) for details.
