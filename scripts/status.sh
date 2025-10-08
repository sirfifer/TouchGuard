#!/bin/bash

# TouchGuard Status Script
# Display current configuration and service status
#
# Usage: ./status.sh

PLIST_PATH="/Library/LaunchDaemons/com.syntaxsoft.touchguard.plist"
BINARY_PATH="/usr/local/bin/TouchGuard"
PLIST_BUDDY="/usr/libexec/PlistBuddy"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BLUE}${BOLD}"
echo "=========================================="
echo "  TouchGuard Status"
echo "=========================================="
echo -e "${NC}"

# Check if TouchGuard is installed
if [ ! -f "$PLIST_PATH" ]; then
    echo -e "${RED}✗ TouchGuard is not installed${NC}"
    echo ""
    echo "To install TouchGuard, visit:"
    echo "  https://github.com/sirfifer/TouchGuard"
    exit 1
fi

# Check service status
echo -e "${BOLD}Service Status:${NC}"
if launchctl list | grep -q "com.syntaxsoft.touchguard"; then
    echo -e "  ${GREEN}●${NC} Running"

    # Get PID if available
    PID=$(launchctl list | grep "com.syntaxsoft.touchguard" | awk '{print $1}')
    if [ "$PID" != "-" ] && [ -n "$PID" ]; then
        echo -e "  PID: $PID"
    fi
else
    echo -e "  ${RED}●${NC} Not running"
fi

echo ""

# Function to get value from plist
get_plist_value() {
    local key="$1"
    local index="$2"
    if [ -z "$index" ]; then
        $PLIST_BUDDY -c "Print :$key" "$PLIST_PATH" 2>/dev/null
    else
        $PLIST_BUDDY -c "Print :ProgramArguments:$index" "$PLIST_PATH" 2>/dev/null
    fi
}

# Function to find argument index
find_arg_index() {
    local arg="$1"
    for ((i=0; i<20; i++)); do
        local val=$(get_plist_value "ProgramArguments" "$i" 2>/dev/null)
        if [ "$val" = "$arg" ]; then
            echo "$i"
            return 0
        fi
    done
    echo "-1"
}

# Get configuration
echo -e "${BOLD}Configuration:${NC}"

TIME_INDEX=$(find_arg_index "-time")
if [ "$TIME_INDEX" != "-1" ]; then
    TIME_VALUE=$(get_plist_value "ProgramArguments" "$((TIME_INDEX + 1))")
    TIME_MS=$(echo "$TIME_VALUE * 1000" | bc)
    echo -e "  Time interval: ${TIME_VALUE}s (${TIME_MS%.*}ms)"
else
    echo "  Time interval: 0.001s (1ms) [default]"
fi

MOVEMENT_INDEX=$(find_arg_index "-blockMovement")
if [ "$MOVEMENT_INDEX" != "-1" ]; then
    echo -e "  Movement blocking: ${GREEN}Enabled${NC}"

    MOVEMENT_TIME_INDEX=$(find_arg_index "-movementTime")
    if [ "$MOVEMENT_TIME_INDEX" != "-1" ]; then
        MOVEMENT_TIME=$(get_plist_value "ProgramArguments" "$((MOVEMENT_TIME_INDEX + 1))")
        MOVEMENT_MS=$(echo "$MOVEMENT_TIME * 1000" | bc)
        echo -e "  Movement interval: ${MOVEMENT_TIME}s (${MOVEMENT_MS%.*}ms)"
    else
        echo "  Movement interval: Same as time interval"
    fi
else
    echo -e "  Movement blocking: ${RED}Disabled${NC}"
fi

# Check for debug flags
if [ "$(find_arg_index '-nodebug')" != "-1" ]; then
    echo "  Debug messages: Disabled"
fi

echo ""

# File paths
echo -e "${BOLD}Files:${NC}"
echo "  Configuration: $PLIST_PATH"

if [ -f "$BINARY_PATH" ]; then
    BINARY_VERSION=$("$BINARY_PATH" -version 2>&1 | head -1)
    echo "  Binary: $BINARY_PATH"
    echo "  Version: $BINARY_VERSION"
else
    echo -e "  Binary: ${RED}Not found${NC} (expected at $BINARY_PATH)"
fi

# Check logs
echo ""
echo -e "${BOLD}Logs:${NC}"
if [ -f "/var/log/touchguard.log" ]; then
    LOG_SIZE=$(du -h "/var/log/touchguard.log" | awk '{print $1}')
    echo "  Output: /var/log/touchguard.log ($LOG_SIZE)"
else
    echo "  Output: /var/log/touchguard.log (not created yet)"
fi

if [ -f "/var/log/touchguard.error.log" ]; then
    ERROR_LOG_SIZE=$(du -h "/var/log/touchguard.error.log" | awk '{print $1}')
    ERROR_LINES=$(wc -l < "/var/log/touchguard.error.log" | tr -d ' ')
    if [ "$ERROR_LINES" -gt 0 ]; then
        echo -e "  Errors: /var/log/touchguard.error.log ($ERROR_LOG_SIZE, ${YELLOW}$ERROR_LINES lines${NC})"
    else
        echo "  Errors: /var/log/touchguard.error.log (no errors)"
    fi
else
    echo "  Errors: /var/log/touchguard.error.log (not created yet)"
fi

echo ""

# Quick actions
echo -e "${BOLD}Quick Actions:${NC}"
echo "  Adjust settings: sudo ./configure.sh --time 0.15"
echo "  Interactive config: sudo ./configure.sh"
echo "  Restart service: sudo launchctl unload $PLIST_PATH && sudo launchctl load -w $PLIST_PATH"
echo "  View logs: tail -f /var/log/touchguard.log"
echo "  Uninstall: sudo ./uninstall.sh"
echo ""
