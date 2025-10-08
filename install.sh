#!/bin/bash

# TouchGuard Installer Script
# This script installs TouchGuard as a LaunchDaemon to run automatically at startup
#
# TouchGuard originally created by SyntaxSoft (Prag Batra)
# https://github.com/thesyntaxinator/TouchGuard
#
# Installation script by sirfifer
# https://github.com/sirfifer/TouchGuard

set -e  # Exit on error

BINARY_NAME="TouchGuard"
PLIST_NAME="com.syntaxsoft.touchguard.plist"
INSTALL_DIR="/usr/local/bin"
LAUNCHDAEMON_DIR="/Library/LaunchDaemons"

echo "======================================"
echo "TouchGuard Installer"
echo "======================================"
echo ""

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run with sudo"
    echo "Usage: sudo ./install.sh"
    exit 1
fi

# Check if binary exists in TouchGuard subdirectory
if [ ! -f "TouchGuard/$BINARY_NAME" ]; then
    echo "Error: TouchGuard binary not found at TouchGuard/$BINARY_NAME"
    echo "Please build the project first using:"
    echo "  cd TouchGuard"
    echo "  cc -o TouchGuard main.c -framework ApplicationServices -framework CoreFoundation"
    exit 1
fi

# Check if plist exists
if [ ! -f "$PLIST_NAME" ]; then
    echo "Error: $PLIST_NAME not found"
    exit 1
fi

echo "Installing TouchGuard..."
echo ""

# Copy binary to /usr/local/bin
echo "1. Copying $BINARY_NAME to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp "TouchGuard/$BINARY_NAME" "$INSTALL_DIR/"
chmod 755 "$INSTALL_DIR/$BINARY_NAME"
echo "   ✓ Binary installed"

# Copy plist to LaunchDaemons
echo "2. Installing LaunchDaemon configuration..."
cp "$PLIST_NAME" "$LAUNCHDAEMON_DIR/"
chmod 644 "$LAUNCHDAEMON_DIR/$PLIST_NAME"
echo "   ✓ Configuration installed"

# Unload existing daemon if it's running
if launchctl list | grep -q "com.syntaxsoft.touchguard"; then
    echo "3. Stopping existing TouchGuard service..."
    launchctl unload "$LAUNCHDAEMON_DIR/$PLIST_NAME" 2>/dev/null || true
    echo "   ✓ Stopped"
fi

# Load the daemon
echo "4. Starting TouchGuard service..."
launchctl load -w "$LAUNCHDAEMON_DIR/$PLIST_NAME"
echo "   ✓ Started"

echo ""
echo "======================================"
echo "Installation Complete!"
echo "======================================"
echo ""
echo "TouchGuard is now running and will start automatically at boot."
echo ""
echo "Configuration file: $LAUNCHDAEMON_DIR/$PLIST_NAME"
echo "To change settings (e.g., time interval), edit this file and run:"
echo "  sudo launchctl unload $LAUNCHDAEMON_DIR/$PLIST_NAME"
echo "  sudo launchctl load -w $LAUNCHDAEMON_DIR/$PLIST_NAME"
echo ""
echo "To uninstall, run: sudo ./uninstall.sh"
echo ""
echo "Logs can be viewed at:"
echo "  /var/log/touchguard.log"
echo "  /var/log/touchguard.error.log"
echo ""
