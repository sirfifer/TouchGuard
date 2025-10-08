#!/bin/bash

# TouchGuard Quick Uninstall Script
# Removes TouchGuard from your system
#
# Usage: curl -fsSL https://raw.githubusercontent.com/sirfifer/TouchGuard/main/scripts/quick-uninstall.sh | sudo bash

BINARY_NAME="TouchGuard"
PLIST_NAME="com.syntaxsoft.touchguard.plist"
INSTALL_DIR="/usr/local/bin"
LAUNCHDAEMON_DIR="/Library/LaunchDaemons"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "=========================================="
echo "  TouchGuard Quick Uninstaller"
echo "=========================================="
echo -e "${NC}"

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run with sudo${NC}"
    echo "Usage: curl -fsSL https://raw.githubusercontent.com/sirfifer/TouchGuard/main/scripts/quick-uninstall.sh | sudo bash"
    exit 1
fi

echo -e "${YELLOW}→${NC} Removing TouchGuard..."
echo ""

# Stop and unload the daemon if it's running
if [ -f "$LAUNCHDAEMON_DIR/$PLIST_NAME" ]; then
    echo "  Stopping TouchGuard service..."
    launchctl unload "$LAUNCHDAEMON_DIR/$PLIST_NAME" 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Stopped"

    echo "  Removing LaunchDaemon configuration..."
    rm -f "$LAUNCHDAEMON_DIR/$PLIST_NAME"
    echo -e "  ${GREEN}✓${NC} Configuration removed"
else
    echo -e "  ${YELLOW}⚠${NC} No LaunchDaemon configuration found (skipping)"
fi

# Remove binary
if [ -f "$INSTALL_DIR/$BINARY_NAME" ]; then
    echo "  Removing binary from $INSTALL_DIR..."
    rm -f "$INSTALL_DIR/$BINARY_NAME"
    echo -e "  ${GREEN}✓${NC} Binary removed"
else
    echo -e "  ${YELLOW}⚠${NC} Binary not found (skipping)"
fi

# Remove logs
if [ -f "/var/log/touchguard.log" ] || [ -f "/var/log/touchguard.error.log" ]; then
    echo "  Removing log files..."
    rm -f /var/log/touchguard.log
    rm -f /var/log/touchguard.error.log
    echo -e "  ${GREEN}✓${NC} Logs removed"
fi

echo ""
echo -e "${GREEN}"
echo "=========================================="
echo "  Uninstallation Complete!"
echo "=========================================="
echo -e "${NC}"
echo ""
echo "TouchGuard has been removed from your system."
echo ""
