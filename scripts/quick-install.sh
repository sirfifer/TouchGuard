#!/bin/bash

# TouchGuard Quick Install Script
# Downloads and installs the latest TouchGuard release from GitHub
#
# Usage: curl -fsSL https://raw.githubusercontent.com/sirfifer/TouchGuard/main/scripts/quick-install.sh | sudo bash

set -e

REPO="sirfifer/TouchGuard"
INSTALL_DIR="/tmp/touchguard-install-$$"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "=========================================="
echo "  TouchGuard Quick Installer"
echo "=========================================="
echo -e "${NC}"

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run with sudo${NC}"
    echo "Usage: curl -fsSL https://raw.githubusercontent.com/${REPO}/main/scripts/quick-install.sh | sudo bash"
    exit 1
fi

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}Error: This script only works on macOS${NC}"
    exit 1
fi

echo -e "${YELLOW}→${NC} Detecting latest version..."

# Get latest release version from GitHub API
LATEST_VERSION=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_VERSION" ]; then
    echo -e "${RED}Error: Could not fetch latest version from GitHub${NC}"
    echo "Please check your internet connection and try again."
    exit 1
fi

echo -e "${GREEN}✓${NC} Latest version: ${LATEST_VERSION}"

# Construct download URL
PACKAGE_NAME="TouchGuard-${LATEST_VERSION}-macos"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${LATEST_VERSION}/${PACKAGE_NAME}.tar.gz"

echo -e "${YELLOW}→${NC} Downloading ${PACKAGE_NAME}.tar.gz..."

# Create temporary directory
mkdir -p "${INSTALL_DIR}"
cd "${INSTALL_DIR}"

# Download release
if ! curl -fsSL "${DOWNLOAD_URL}" -o "${PACKAGE_NAME}.tar.gz"; then
    echo -e "${RED}Error: Failed to download release${NC}"
    echo "URL: ${DOWNLOAD_URL}"
    rm -rf "${INSTALL_DIR}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Downloaded successfully"

echo -e "${YELLOW}→${NC} Extracting package..."

# Extract tarball
tar -xzf "${PACKAGE_NAME}.tar.gz"

if [ ! -d "${PACKAGE_NAME}" ]; then
    echo -e "${RED}Error: Package extraction failed${NC}"
    rm -rf "${INSTALL_DIR}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Extracted"

echo -e "${YELLOW}→${NC} Running installer..."
echo ""

# Change to package directory and run install script
cd "${PACKAGE_NAME}"

# Make install script executable
chmod +x install.sh

# Run installation
./install.sh

# Clean up
echo ""
echo -e "${YELLOW}→${NC} Cleaning up temporary files..."
cd /
rm -rf "${INSTALL_DIR}"

echo -e "${GREEN}✓${NC} Cleanup complete"
echo ""
echo -e "${GREEN}"
echo "=========================================="
echo "  Installation Complete!"
echo "=========================================="
echo -e "${NC}"
echo ""
echo "TouchGuard ${LATEST_VERSION} has been installed."
echo ""
echo -e "${BLUE}To uninstall:${NC}"
echo "  curl -fsSL https://raw.githubusercontent.com/${REPO}/main/scripts/quick-uninstall.sh | sudo bash"
echo ""
echo -e "${BLUE}For support:${NC} https://github.com/${REPO}/issues"
echo ""
