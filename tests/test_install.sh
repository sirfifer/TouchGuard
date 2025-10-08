#!/bin/bash

# TouchGuard Installation Tests
# Tests install.sh and uninstall.sh without actually installing (dry-run checks)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((TESTS_PASSED++))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    ((TESTS_FAILED++))
}

info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

echo "========================================"
echo "TouchGuard Installation Tests"
echo "========================================"
echo ""

# Test 1: Check install.sh exists
echo "Test 1: install.sh exists"
if [ -f "$PROJECT_ROOT/install.sh" ]; then
    pass "install.sh file exists"
else
    fail "install.sh file not found"
fi

# Test 2: Check install.sh is executable
echo ""
echo "Test 2: install.sh is executable"
if [ -x "$PROJECT_ROOT/install.sh" ]; then
    pass "install.sh has execute permissions"
else
    fail "install.sh is not executable"
fi

# Test 3: Check uninstall.sh exists
echo ""
echo "Test 3: uninstall.sh exists"
if [ -f "$PROJECT_ROOT/uninstall.sh" ]; then
    pass "uninstall.sh file exists"
else
    fail "uninstall.sh file not found"
fi

# Test 4: Check uninstall.sh is executable
echo ""
echo "Test 4: uninstall.sh is executable"
if [ -x "$PROJECT_ROOT/uninstall.sh" ]; then
    pass "uninstall.sh has execute permissions"
else
    fail "uninstall.sh is not executable"
fi

# Test 5: Check plist file exists
echo ""
echo "Test 5: LaunchDaemon plist exists"
if [ -f "$PROJECT_ROOT/com.syntaxsoft.touchguard.plist" ]; then
    pass "LaunchDaemon plist file exists"
else
    fail "LaunchDaemon plist file not found"
fi

# Test 6: Validate plist file syntax
echo ""
echo "Test 6: Validate plist syntax"
if plutil -lint "$PROJECT_ROOT/com.syntaxsoft.touchguard.plist" > /dev/null 2>&1; then
    pass "LaunchDaemon plist has valid syntax"
else
    fail "LaunchDaemon plist has invalid syntax"
fi

# Test 7: Check plist contains required keys
echo ""
echo "Test 7: Plist contains Label key"
if grep -q "<key>Label</key>" "$PROJECT_ROOT/com.syntaxsoft.touchguard.plist"; then
    pass "Plist contains Label key"
else
    fail "Plist missing Label key"
fi

echo ""
echo "Test 8: Plist contains ProgramArguments key"
if grep -q "<key>ProgramArguments</key>" "$PROJECT_ROOT/com.syntaxsoft.touchguard.plist"; then
    pass "Plist contains ProgramArguments key"
else
    fail "Plist missing ProgramArguments key"
fi

echo ""
echo "Test 9: Plist contains RunAtLoad key"
if grep -q "<key>RunAtLoad</key>" "$PROJECT_ROOT/com.syntaxsoft.touchguard.plist"; then
    pass "Plist contains RunAtLoad key"
else
    fail "Plist missing RunAtLoad key"
fi

# Test 10: Check binary path in plist
echo ""
echo "Test 10: Plist references correct binary path"
if grep -q "/usr/local/bin/TouchGuard" "$PROJECT_ROOT/com.syntaxsoft.touchguard.plist"; then
    pass "Plist references /usr/local/bin/TouchGuard"
else
    fail "Plist doesn't reference correct binary path"
fi

# Test 11: Install script checks for sudo
echo ""
echo "Test 11: Install script requires sudo"
if grep -q 'EUID.*-ne.*0' "$PROJECT_ROOT/install.sh"; then
    pass "Install script checks for root/sudo"
else
    fail "Install script doesn't check for sudo"
fi

# Test 12: Uninstall script checks for sudo
echo ""
echo "Test 12: Uninstall script requires sudo"
if grep -q 'EUID.*-ne.*0' "$PROJECT_ROOT/uninstall.sh"; then
    pass "Uninstall script checks for root/sudo"
else
    fail "Uninstall script doesn't check for sudo"
fi

# Test 13: Binary exists for installation
echo ""
echo "Test 13: TouchGuard binary exists"
if [ -f "$PROJECT_ROOT/TouchGuard/TouchGuard" ]; then
    pass "TouchGuard binary exists for installation"
else
    info "TouchGuard binary not built yet (run build first)"
fi

# Summary
echo ""
echo "========================================"
echo "Test Results"
echo "========================================"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All installation tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed${NC}"
    exit 1
fi
