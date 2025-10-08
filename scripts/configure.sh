#!/bin/bash

# TouchGuard Configuration Script
# Easily adjust TouchGuard settings without manually editing the plist file
#
# Usage:
#   sudo ./configure.sh                           # Interactive mode
#   sudo ./configure.sh --time 0.15               # Set time interval
#   sudo ./configure.sh --block-movement          # Enable movement blocking
#   sudo ./configure.sh --time 0.2 --movement-time 0.1  # Set both intervals
#   sudo ./configure.sh --disable-movement        # Disable movement blocking
#   sudo ./configure.sh --help                    # Show help

PLIST_PATH="/Library/LaunchDaemons/com.syntaxsoft.touchguard.plist"
PLIST_BUDDY="/usr/libexec/PlistBuddy"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_help() {
    echo "TouchGuard Configuration Tool"
    echo ""
    echo "Usage:"
    echo "  sudo ./configure.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --time <seconds>          Set tap blocking interval (e.g., 0.2)"
    echo "  --block-movement          Enable cursor movement blocking"
    echo "  --disable-movement        Disable cursor movement blocking"
    echo "  --movement-time <seconds> Set movement blocking interval"
    echo "  --help                    Show this help message"
    echo ""
    echo "Examples:"
    echo "  sudo ./configure.sh --time 0.15"
    echo "  sudo ./configure.sh --time 0.2 --block-movement --movement-time 0.1"
    echo "  sudo ./configure.sh --disable-movement"
    echo ""
    echo "Interactive mode (prompts for all settings):"
    echo "  sudo ./configure.sh"
    echo ""
}

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run with sudo${NC}"
    echo "Usage: sudo ./configure.sh [OPTIONS]"
    exit 1
fi

# Check if TouchGuard is installed
if [ ! -f "$PLIST_PATH" ]; then
    echo -e "${RED}Error: TouchGuard is not installed${NC}"
    echo "Please install TouchGuard first using install.sh"
    exit 1
fi

# Show help if requested
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_help
    exit 0
fi

echo -e "${BLUE}"
echo "=========================================="
echo "  TouchGuard Configuration"
echo "=========================================="
echo -e "${NC}"

# Function to get current value from plist
get_plist_value() {
    local key="$1"
    local index="$2"
    if [ -z "$index" ]; then
        $PLIST_BUDDY -c "Print :$key" "$PLIST_PATH" 2>/dev/null
    else
        $PLIST_BUDDY -c "Print :ProgramArguments:$index" "$PLIST_PATH" 2>/dev/null
    fi
}

# Function to find argument index in ProgramArguments array
find_arg_index() {
    local arg="$1"
    local count=$($PLIST_BUDDY -c "Print :ProgramArguments" "$PLIST_PATH" | grep -c "Dict")
    local array_size=$($PLIST_BUDDY -c "Print :ProgramArguments" "$PLIST_PATH" | grep -c "    ")

    for ((i=0; i<20; i++)); do
        local val=$(get_plist_value "ProgramArguments" "$i" 2>/dev/null)
        if [ "$val" = "$arg" ]; then
            echo "$i"
            return 0
        fi
    done
    echo "-1"
}

# Get current settings
echo -e "${YELLOW}→${NC} Reading current configuration..."
echo ""

TIME_INDEX=$(find_arg_index "-time")
if [ "$TIME_INDEX" != "-1" ]; then
    CURRENT_TIME=$(get_plist_value "ProgramArguments" "$((TIME_INDEX + 1))")
else
    CURRENT_TIME="0.001"
fi

MOVEMENT_ENABLED=false
MOVEMENT_INDEX=$(find_arg_index "-blockMovement")
if [ "$MOVEMENT_INDEX" != "-1" ]; then
    MOVEMENT_ENABLED=true
fi

MOVEMENT_TIME_INDEX=$(find_arg_index "-movementTime")
if [ "$MOVEMENT_TIME_INDEX" != "-1" ]; then
    CURRENT_MOVEMENT_TIME=$(get_plist_value "ProgramArguments" "$((MOVEMENT_TIME_INDEX + 1))")
else
    CURRENT_MOVEMENT_TIME="$CURRENT_TIME"
fi

echo "Current Settings:"
echo "  Time interval: ${CURRENT_TIME} seconds"
if [ "$MOVEMENT_ENABLED" = true ]; then
    echo "  Movement blocking: ${GREEN}Enabled${NC}"
    echo "  Movement interval: ${CURRENT_MOVEMENT_TIME} seconds"
else
    echo "  Movement blocking: ${RED}Disabled${NC}"
fi
echo ""

# Parse command-line arguments or go interactive
NEW_TIME=""
NEW_MOVEMENT_TIME=""
SET_BLOCK_MOVEMENT=""

if [ $# -eq 0 ]; then
    # Interactive mode
    echo -e "${BLUE}Interactive Configuration${NC}"
    echo "(Press Enter to keep current value)"
    echo ""

    read -p "Time interval in seconds [$CURRENT_TIME]: " input
    if [ -n "$input" ]; then
        NEW_TIME="$input"
    fi

    read -p "Enable movement blocking? (y/n) [$([ "$MOVEMENT_ENABLED" = true ] && echo 'y' || echo 'n')]: " input
    if [ -n "$input" ]; then
        if [[ "$input" =~ ^[Yy]$ ]]; then
            SET_BLOCK_MOVEMENT="true"
            read -p "Movement time interval in seconds [$CURRENT_MOVEMENT_TIME]: " input
            if [ -n "$input" ]; then
                NEW_MOVEMENT_TIME="$input"
            fi
        else
            SET_BLOCK_MOVEMENT="false"
        fi
    fi
else
    # Command-line mode
    while [[ $# -gt 0 ]]; do
        case $1 in
            --time)
                NEW_TIME="$2"
                shift 2
                ;;
            --movement-time)
                NEW_MOVEMENT_TIME="$2"
                shift 2
                ;;
            --block-movement)
                SET_BLOCK_MOVEMENT="true"
                shift
                ;;
            --disable-movement)
                SET_BLOCK_MOVEMENT="false"
                shift
                ;;
            *)
                echo -e "${RED}Error: Unknown option $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
fi

# Validate inputs
if [ -n "$NEW_TIME" ]; then
    if ! [[ "$NEW_TIME" =~ ^[0-9]*\.?[0-9]+$ ]] || [ "$(echo "$NEW_TIME <= 0" | bc)" -eq 1 ]; then
        echo -e "${RED}Error: Time must be a positive number${NC}"
        exit 1
    fi
fi

if [ -n "$NEW_MOVEMENT_TIME" ]; then
    if ! [[ "$NEW_MOVEMENT_TIME" =~ ^[0-9]*\.?[0-9]+$ ]] || [ "$(echo "$NEW_MOVEMENT_TIME <= 0" | bc)" -eq 1 ]; then
        echo -e "${RED}Error: Movement time must be a positive number${NC}"
        exit 1
    fi
fi

# Check if any changes were requested
if [ -z "$NEW_TIME" ] && [ -z "$NEW_MOVEMENT_TIME" ] && [ -z "$SET_BLOCK_MOVEMENT" ]; then
    echo -e "${YELLOW}No changes requested${NC}"
    exit 0
fi

echo ""
echo -e "${YELLOW}→${NC} Updating configuration..."

# Backup plist
cp "$PLIST_PATH" "${PLIST_PATH}.backup"

# Update time interval
if [ -n "$NEW_TIME" ]; then
    if [ "$TIME_INDEX" != "-1" ]; then
        $PLIST_BUDDY -c "Set :ProgramArguments:$((TIME_INDEX + 1)) $NEW_TIME" "$PLIST_PATH"
    else
        # Add -time argument
        $PLIST_BUDDY -c "Add :ProgramArguments: string -time" "$PLIST_PATH"
        $PLIST_BUDDY -c "Add :ProgramArguments: string $NEW_TIME" "$PLIST_PATH"
    fi
    echo "  ✓ Time interval set to ${NEW_TIME} seconds"
fi

# Update movement blocking
if [ "$SET_BLOCK_MOVEMENT" = "true" ]; then
    if [ "$MOVEMENT_INDEX" = "-1" ]; then
        # Add -blockMovement flag
        $PLIST_BUDDY -c "Add :ProgramArguments: string -blockMovement" "$PLIST_PATH"
        echo "  ✓ Movement blocking enabled"
    fi

    # Update movement time if specified
    if [ -n "$NEW_MOVEMENT_TIME" ]; then
        MOVEMENT_TIME_INDEX=$(find_arg_index "-movementTime")
        if [ "$MOVEMENT_TIME_INDEX" != "-1" ]; then
            $PLIST_BUDDY -c "Set :ProgramArguments:$((MOVEMENT_TIME_INDEX + 1)) $NEW_MOVEMENT_TIME" "$PLIST_PATH"
        else
            $PLIST_BUDDY -c "Add :ProgramArguments: string -movementTime" "$PLIST_PATH"
            $PLIST_BUDDY -c "Add :ProgramArguments: string $NEW_MOVEMENT_TIME" "$PLIST_PATH"
        fi
        echo "  ✓ Movement time interval set to ${NEW_MOVEMENT_TIME} seconds"
    fi
elif [ "$SET_BLOCK_MOVEMENT" = "false" ]; then
    # Remove movement blocking flags
    if [ "$MOVEMENT_INDEX" != "-1" ]; then
        # Remove in reverse order to maintain indices
        MOVEMENT_TIME_INDEX=$(find_arg_index "-movementTime")
        if [ "$MOVEMENT_TIME_INDEX" != "-1" ]; then
            $PLIST_BUDDY -c "Delete :ProgramArguments:$((MOVEMENT_TIME_INDEX + 1))" "$PLIST_PATH"
            $PLIST_BUDDY -c "Delete :ProgramArguments:$MOVEMENT_TIME_INDEX" "$PLIST_PATH"
        fi
        # Refresh index after deletions
        MOVEMENT_INDEX=$(find_arg_index "-blockMovement")
        if [ "$MOVEMENT_INDEX" != "-1" ]; then
            $PLIST_BUDDY -c "Delete :ProgramArguments:$MOVEMENT_INDEX" "$PLIST_PATH"
        fi
        echo "  ✓ Movement blocking disabled"
    fi
fi

# Validate plist
if ! plutil -lint "$PLIST_PATH" > /dev/null 2>&1; then
    echo -e "${RED}Error: Updated plist is invalid. Restoring backup.${NC}"
    mv "${PLIST_PATH}.backup" "$PLIST_PATH"
    exit 1
fi

# Remove backup
rm -f "${PLIST_PATH}.backup"

echo ""
echo -e "${YELLOW}→${NC} Restarting TouchGuard service..."

# Restart service
launchctl unload "$PLIST_PATH" 2>/dev/null || true
sleep 1
launchctl load -w "$PLIST_PATH"

# Verify service is running
sleep 1
if launchctl list | grep -q "com.syntaxsoft.touchguard"; then
    echo -e "  ${GREEN}✓${NC} Service restarted successfully"
else
    echo -e "  ${YELLOW}⚠${NC} Service may not be running. Check logs at /var/log/touchguard.error.log"
fi

echo ""
echo -e "${GREEN}"
echo "=========================================="
echo "  Configuration Updated!"
echo "=========================================="
echo -e "${NC}"
echo ""
echo "To check current status:"
echo "  ./status.sh"
echo ""
