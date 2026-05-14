#!/bin/bash
#
# install_ninja.sh — Download and install the latest Ninja build system.
#
# Usage:
#   ./install_ninja.sh

set -euo pipefail

# Fetch the latest version tag from GitHub
NINJA_VERSION=$(curl -s "https://api.github.com/repos/ninja-build/ninja/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')

echo "==> Latest Ninja version: ${NINJA_VERSION}"

# Download and extract
ZIP_FILE="ninja-linux-${NINJA_VERSION}.zip"
DOWNLOAD_URL="https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/ninja-linux.zip"

echo "==> Downloading ${DOWNLOAD_URL} ..."
curl -Lo "${ZIP_FILE}" "${DOWNLOAD_URL}"

echo "==> Extracting ${ZIP_FILE} ..."
unzip -o "${ZIP_FILE}"

echo "==> Installing ninja to /usr/local/bin ..."
sudo install ninja /usr/local/bin

# Cleanup
rm -f ninja "${ZIP_FILE}"

echo "==> Ninja ${NINJA_VERSION} installed successfully."
