# AGENTS.md

This file provides context and instructions for AI agents working on this codebase.

## Project Overview

TouchGuard is a macOS utility written in C that prevents accidental trackpad input while typing. It works by creating a system-wide event tap to intercept keyboard and mouse events.

## Key Files

-   `TouchGuard/main.c`: The core application logic (single-file C program).
-   `TouchGuard.xcodeproj`: Xcode project definition.
-   `Makefile`: Build automation for CLI usage.
-   `install.sh` / `uninstall.sh`: Installation scripts for the LaunchDaemon.
-   `tests/`: Shell scripts for automated testing.

## Build & Test

**Build:**
```bash
make build
```

**Test:**
```bash
make test
```

## Architecture Notes

-   **Event Tap**: Uses `CGEventTapCreate` with `kCGHIDEventTap` to intercept events at the lowest possible level. This requires **root privileges** (`sudo`).
-   **Threading**: Uses Grand Central Dispatch (GCD) for timers (`dispatch_after_f`) to re-enable the trackpad after a delay.
-   **State**: Global state is managed via bitwise flags (`mgi_flag`) and static variables.

## Common Tasks

-   **Update Version**: Modify `MAJOR_VERSION`, `MINOR_VERSION`, `PATCH_VERSION` in `TouchGuard/main.c`.
-   **Add Feature**: Modify `eventCallBack` in `TouchGuard/main.c` to handle new event types.
-   **Debug**: Use `printf` (standard output) for logging. Debug messages are controlled by the `-nodebug` flag.
