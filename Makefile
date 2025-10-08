# TouchGuard Makefile
# Builds the binary and runs tests

CC = cc
CFLAGS = -Wall -Wextra -O2
FRAMEWORKS = -framework ApplicationServices -framework CoreFoundation
SRC_DIR = TouchGuard
BUILD_DIR = build
TEST_DIR = tests

BINARY = $(SRC_DIR)/TouchGuard
SOURCE = $(SRC_DIR)/main.c

.PHONY: all build test test-cli test-install clean help

# Default target
all: build

# Build the TouchGuard binary
build:
	@echo "Building TouchGuard..."
	@mkdir -p $(SRC_DIR)
	$(CC) $(CFLAGS) -o $(BINARY) $(SOURCE) $(FRAMEWORKS)
	@echo "✓ Build complete: $(BINARY)"

# Run all tests
test: test-install test-cli
	@echo ""
	@echo "========================================"
	@echo "All Tests Complete"
	@echo "========================================"

# Run CLI tests
test-cli: build
	@echo ""
	@echo "Running CLI tests..."
	@$(TEST_DIR)/test_cli.sh

# Run installation tests
test-install:
	@echo ""
	@echo "Running installation tests..."
	@$(TEST_DIR)/test_install.sh

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -f $(BINARY)
	@rm -rf $(BUILD_DIR)
	@echo "✓ Clean complete"

# Show help
help:
	@echo "TouchGuard Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  make build         - Build the TouchGuard binary"
	@echo "  make test          - Run all tests"
	@echo "  make test-cli      - Run CLI tests only"
	@echo "  make test-install  - Run installation tests only"
	@echo "  make clean         - Remove build artifacts"
	@echo "  make help          - Show this help message"
