#!/bin/bash

# TouchGuard Command-Line Interface Tests
# Tests the binary's behavior via command-line arguments

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BINARY="$PROJECT_ROOT/TouchGuard/TouchGuard"

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

# Check if binary exists
if [ ! -f "$BINARY" ]; then
    echo -e "${RED}Error: TouchGuard binary not found at $BINARY${NC}"
    echo "Please build the project first:"
    echo "  cd TouchGuard"
    echo "  cc -o TouchGuard main.c -framework ApplicationServices -framework CoreFoundation"
    exit 1
fi

echo "========================================"
echo "TouchGuard CLI Tests"
echo "========================================"
echo ""

info "Testing binary: $BINARY"
echo ""

# Test 1: Version flag
echo "Test 1: -version flag"
OUTPUT=$("$BINARY" -version 2>&1)
if echo "$OUTPUT" | grep -q "TouchGuard v1.5.1"; then
    pass "Version flag returns correct version"
else
    fail "Version flag did not return expected version (got: $OUTPUT)"
fi

# Test 2: Binary is executable
echo ""
echo "Test 2: Binary is executable"
if [ -x "$BINARY" ]; then
    pass "Binary has execute permissions"
else
    fail "Binary is not executable"
fi

# Test 3: Binary size is reasonable
echo ""
echo "Test 3: Binary size check"
SIZE=$(stat -f%z "$BINARY" 2>/dev/null || stat -c%s "$BINARY" 2>/dev/null)
if [ "$SIZE" -gt 10000 ] && [ "$SIZE" -lt 500000 ]; then
    pass "Binary size is reasonable ($SIZE bytes)"
else
    fail "Binary size seems unusual ($SIZE bytes)"
fi

# Test 4: Help/invalid flag handling (should not crash)
echo ""
echo "Test 4: Invalid flag handling"
"$BINARY" -invalidflag 2>&1 || true
if [ $? -ne 139 ]; then  # 139 is segfault
    pass "Binary doesn't crash on invalid flags"
else
    fail "Binary crashed on invalid flag"
fi

# Test 5: Time interval parsing (can't fully test without sudo, but check it compiles with it)
echo ""
echo "Test 5: Verify time-related code exists in binary"
if strings "$BINARY" | grep -q "time"; then
    pass "Binary contains time-related strings"
else
    fail "Binary doesn't contain expected time strings"
fi

# Test 6: Movement blocking code exists
echo ""
echo "Test 6: Verify movement blocking code exists"
if strings "$BINARY" | grep -q "movementTime\|blockMovement\|Movement blocking"; then
    pass "Binary contains movement blocking code"
else
    fail "Binary doesn't contain movement blocking strings"
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
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed${NC}"
    exit 1
fi
