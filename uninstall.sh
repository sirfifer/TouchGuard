#!/bin/bash

# TouchGuard Uninstaller Script
# This script removes TouchGuard from your system
#
# TouchGuard originally created by SyntaxSoft (Prag Batra)
# https://github.com/thesyntaxinator/TouchGuard
#
# Uninstallation script by sirfifer
# https://github.com/sirfifer/TouchGuard

set -e  # Exit on error

BINARY_NAME="TouchGuard"
PLIST_NAME="com.syntaxsoft.touchguard.plist"
INSTALL_DIR="/usr/local/bin"
LAUNCHDAEMON_DIR="/Library/LaunchDaemons"

echo "======================================"
echo "TouchGuard Uninstaller"
echo "======================================"
echo ""

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run with sudo"
    echo "Usage: sudo ./uninstall.sh"
    exit 1
fi

echo "Removing TouchGuard..."
echo ""

# Stop and unload the daemon if it's running
if [ -f "$LAUNCHDAEMON_DIR/$PLIST_NAME" ]; then
    echo "1. Stopping TouchGuard service..."
    launchctl unload "$LAUNCHDAEMON_DIR/$PLIST_NAME" 2>/dev/null || true
    echo "   ✓ Stopped"

    echo "2. Removing LaunchDaemon configuration..."
    rm -f "$LAUNCHDAEMON_DIR/$PLIST_NAME"
    echo "   ✓ Configuration removed"
else
    echo "1. No LaunchDaemon configuration found (skipping)"
fi

# Remove binary
if [ -f "$INSTALL_DIR/$BINARY_NAME" ]; then
    echo "3. Removing binary from $INSTALL_DIR..."
    rm -f "$INSTALL_DIR/$BINARY_NAME"
    echo "   ✓ Binary removed"
else
    echo "3. Binary not found (skipping)"
fi

# Optional: Remove logs
if [ -f "/var/log/touchguard.log" ] || [ -f "/var/log/touchguard.error.log" ]; then
    read -p "Remove log files? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f /var/log/touchguard.log
        rm -f /var/log/touchguard.error.log
        echo "   ✓ Logs removed"
    else
        echo "   Logs kept at:"
        echo "     /var/log/touchguard.log"
        echo "     /var/log/touchguard.error.log"
    fi
fi

echo ""
echo "======================================"
echo "Uninstallation Complete!"
echo "======================================"
echo ""
echo "TouchGuard has been removed from your system."
echo ""
