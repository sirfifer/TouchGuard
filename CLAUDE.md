# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TouchGuard is a macOS command-line utility written in C that temporarily disables the trackpad when keyboard keys are pressed. This prevents accidental cursor movements from palm touches while typing. The application uses macOS Core Graphics event taps to intercept keyboard and mouse events.

**Critical Requirements:**
- Must run with administrative/root privileges (sudo) to access system-level event taps
- Uses `CGEventTapCreate` with `kCGHIDEventTap` which requires elevated permissions
- Single-file architecture: all code is in [TouchGuard/main.c](TouchGuard/main.c)

## Build System

This project uses Xcode for building. The Xcode project file is located at [TouchGuard.xcodeproj/](TouchGuard.xcodeproj/).

**Build commands:**
```bash
# Build using Xcode command line tools (requires full Xcode installation)
xcodebuild -project TouchGuard.xcodeproj -configuration Release

# The built binary will be located at:
# build/Release/TouchGuard

# Or compile directly with cc (works with Command Line Tools only):
cd TouchGuard
cc -o TouchGuard main.c -framework ApplicationServices -framework CoreFoundation

# Or open in Xcode GUI:
open TouchGuard.xcodeproj
```

**Build configurations:**
- Debug: Includes debug symbols, defined at line 132-173 in project.pbxproj
- Release: Optimized build, defined at line 175-209 in project.pbxproj
- Target deployment: macOS 10.11+
- C language standard: gnu99

## Running the Application

The application must be run with sudo:

```bash
sudo ./TouchGuard -time 0.2
```

**Command-line arguments:**
- `-time <seconds>`: Duration (in seconds) to disable touchpad clicks after each keypress (e.g., 0.2 = 200ms)
- `-blockMovement`: Enable cursor movement blocking (in addition to click blocking)
- `-movementTime <seconds>`: Duration to block cursor movement (defaults to `-time` value if not specified)
- `-nodebug`: Suppress debug messages
- `-version`: Display version information
- `-TapEnableMsg`: Show messages when tap is re-enabled
- `-TapDisableMsg`: Show messages when tap is disabled
- `-TapIgnoreMsg`: Show messages when taps are ignored (enabled by default)

**Examples:**
```bash
# Block clicks for 200ms only (default behavior)
sudo ./TouchGuard -time 0.2

# Block both clicks and cursor movement for 200ms
sudo ./TouchGuard -time 0.2 -blockMovement

# Block clicks for 200ms and cursor movement for 100ms
sudo ./TouchGuard -time 0.2 -blockMovement -movementTime 0.1
```

## Code Architecture

### Event Flow
1. **Event Tap Setup** ([main.c:283](TouchGuard/main.c#L283)): Creates a `CGEventTap` that intercepts all system events
2. **Event Callback** ([main.c:150-206](TouchGuard/main.c#L150)): Processes keyboard and mouse events
   - On `kCGEventKeyUp`: Calls `dispatchDisableTap()` to start the disable timer(s)
   - On mouse clicks while disabled: Returns `NULL` to suppress the event
   - On cursor movement while disabled (if `-blockMovement` enabled): Returns `NULL` to suppress movement
3. **Timer Mechanism**: Uses Grand Central Dispatch (GCD) with separate timers for clicks and movement
   - `dispatchCallBack` ([main.c:55-94](TouchGuard/main.c#L55)): Re-enables clicks after tap interval
   - `movementDispatchCallBack` ([main.c:96-113](TouchGuard/main.c#L96)): Re-enables cursor movement after movement interval
   - `dispatchDisableTap` ([main.c:116-146](TouchGuard/main.c#L116)): Disables both taps and movement (if enabled), scheduling separate timers
4. **Run Loop** ([main.c:293](TouchGuard/main.c#L293)): Keeps the application running to process events

### Key Global Variables
- `mgi_flag` (line 29): Bitfield containing application state flags
- `timerInterval` (line 30): Click disable duration in milliseconds
- `movementTimerInterval` (line 31): Movement disable duration in milliseconds (-1 means use timerInterval)
- `dispatchCount` (line 52): Counter to track scheduled click timer callbacks
- `movementDispatchCount` (line 53): Counter to track scheduled movement timer callbacks
- `consecutiveDisableCount`, `consecutiveIgnoreCount`, `consecutiveMovementIgnoreCount` (lines 32-34): Debug counters

### State Flags (defined lines 18-26)
- `DISABLE_TAP_PB`: Indicates touchpad clicks are currently disabled
- `DISABLE_MOVEMENT`: Indicates cursor movement is currently disabled
- `BLOCK_MOVEMENT_ENABLED`: Feature flag - movement blocking is enabled
- `DISABLE_DEBUG_MESSAGES`: Suppresses debug output
- `ENABLE_TAPENABLE_MESSSAGE`: Shows tap re-enable messages
- `ENABLE_TAPDISABLE_MESSAGE`: Shows tap disable messages
- `ENABLE_TAPIGNORE_MESSAGE`: Shows ignored tap messages
- `ENABLE_MOVEMENTIGNORE_MSG`: Shows ignored movement messages

### Critical Implementation Details
- Timer callbacks use count matching to prevent race conditions:
  - `dispatchCallBack` only re-enables taps if its count matches `dispatchCount`
  - `movementDispatchCallBack` only re-enables movement if its count matches `movementDispatchCount`
- Movement blocking intercepts these event types: `kCGEventMouseMoved`, `kCGEventLeftMouseDragged`, `kCGEventRightMouseDragged`, `kCGEventOtherMouseDragged`
- Click blocking intercepts: `kCGEventLeftMouseDown`, `kCGEventLeftMouseUp`, `kCGEventRightMouseDown`, `kCGEventRightMouseUp`
- Blocked events return `NULL`, which tells the system to discard them
- The application uses `CFRunLoopRun()` which blocks forever—terminating requires killing the process

## Testing

There are no automated tests. Testing must be done manually:

**Testing click blocking (default behavior):**
1. Build the application
2. Run with sudo and a test time interval: `sudo ./TouchGuard -time 0.15`
3. Type on the keyboard and attempt to click/tap the trackpad immediately after
4. Verify that taps are ignored during the disable interval
5. Verify that taps work normally after the interval expires
6. Test different time intervals to find optimal values

**Testing movement blocking:**
1. Run with movement blocking enabled: `sudo ./TouchGuard -time 0.2 -blockMovement -movementTime 0.1`
2. Type on the keyboard and attempt to move the cursor immediately after
3. Verify that cursor movement is blocked during the movement interval
4. Verify that cursor movement works normally after the interval expires
5. Test with different `-movementTime` values (shorter intervals like 0.05-0.15s work well for movement)
6. Test without `-movementTime` to verify it falls back to the `-time` value

## Version Information

Current version is defined in [main.c:14-15](TouchGuard/main.c#L14):
- `MAJOR_VERSION = 1`
- `MINOR_VERSION = 4`

When updating the version, modify these constants.
