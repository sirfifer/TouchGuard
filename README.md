# TouchGuard

Disables Mac touchpad for a user-specified amount of time each time a key is pressed on the keyboard. This prevents accidental touchpad input (e.g. palm of hand moving over the edge of the touchpad) from being detected as a tap and causing the cursor to jump to a different line while the user is typing.

**[Download Latest Release](https://github.com/sirfifer/TouchGuard/releases/latest)** | **[View All Releases](https://github.com/sirfifer/TouchGuard/releases)**

*NOTE: Requires administrative privileges (sudo).*

----------------
## Permissions & Security

TouchGuard requires **root privileges** (`sudo`) to function. This is because it uses a low-level Event Tap (`kCGHIDEventTap`) to intercept keyboard and mouse events before they reach the window server.

**Why sudo?**
-   **Reliability**: `kCGHIDEventTap` is the most reliable way to intercept events globally, regardless of which application is focused.
-   **Alternative**: The alternative is using Accessibility permissions, which requires the user to manually grant permission in System Settings. However, for a LaunchDaemon that runs on boot, `sudo` is the standard and most robust approach.

**Security Note**:
Since this application runs as root and intercepts all input events, you should only run it if you trust the source. The source code is available for review in this repository.

----------------
## Installation

### Quick Install (One Command)

The easiest way to install TouchGuard:

```bash
curl -fsSL https://raw.githubusercontent.com/sirfifer/TouchGuard/main/scripts/quick-install.sh | sudo bash
```

This downloads and installs the latest version automatically. TouchGuard will start immediately and run automatically on boot.

**To uninstall:**
```bash
curl -fsSL https://raw.githubusercontent.com/sirfifer/TouchGuard/main/scripts/quick-uninstall.sh | sudo bash
```

### Manual Install

If you prefer to download and install manually:

1. **Download** the latest release: [TouchGuard-v1.5.0-macos.tar.gz](https://github.com/sirfifer/TouchGuard/releases/latest)
2. **Extract** the archive:
   ```bash
   tar -xzf TouchGuard-v1.5.0-macos.tar.gz
   cd TouchGuard-v1.5.0-macos
   ```
3. **Install**:
   ```bash
   sudo ./install.sh
   ```

TouchGuard is now running and will automatically start every time you boot your Mac.

**To uninstall:**
```bash
sudo ./uninstall.sh
```

----------------
## Adjusting Settings

After installation, you can easily adjust the time intervals or enable/disable features:

### Quick Adjustment

Change settings with a single command:

```bash
# Change time interval
sudo ./configure.sh --time 0.15

# Enable movement blocking
sudo ./configure.sh --block-movement

# Set different intervals for clicks and movement
sudo ./configure.sh --time 0.2 --movement-time 0.1

# Disable movement blocking
sudo ./configure.sh --disable-movement
```

### Interactive Configuration

Run without arguments to be prompted for settings:

```bash
sudo ./configure.sh
```

### Check Current Settings

View your current configuration:

```bash
./status.sh
```

This shows:
- Service status (running/stopped)
- Current time intervals
- Movement blocking status
- File locations
- Recent logs

### Advanced: Manual Configuration

If you prefer to edit the configuration file directly, you can modify `/Library/LaunchDaemons/com.syntaxsoft.touchguard.plist`. After editing, restart the service:

```bash
sudo launchctl unload /Library/LaunchDaemons/com.syntaxsoft.touchguard.plist
sudo launchctl load -w /Library/LaunchDaemons/com.syntaxsoft.touchguard.plist
```

----------------
## Manual Usage (Advanced)

If you prefer to run TouchGuard manually without installing it as a system service:

```bash
# Make the binary executable
chmod +x TouchGuard/TouchGuard

# Run it (Terminal window must stay open)
sudo ./TouchGuard/TouchGuard -time 0.2
```

**Additional options:**
- `-time <seconds>`: Duration to disable touchpad clicks (default: 0.001)
- `-blockMovement`: Also block cursor movement (not just clicks)
- `-movementTime <seconds>`: Duration to block movement (defaults to `-time` value)
- `-nodebug`: Suppress debug messages
- `-version`: Display version information

**Examples:**
```bash
# Block clicks for 200ms
sudo ./TouchGuard/TouchGuard -time 0.2

# Block clicks for 200ms and cursor movement for 100ms
sudo ./TouchGuard/TouchGuard -time 0.2 -blockMovement -movementTime 0.1
```

The time interval of 200ms (0.2 seconds) works well for most users. If you're still experiencing issues (cursor jumps while typing) or the trackpad feels unresponsive after typing, adjust the interval up or down as needed.

----------------
## Development & Testing

**Build from source:**
```bash
make build
```

**Run tests:**
```bash
make test           # Run all tests
make test-install   # Test installation scripts only
make test-cli       # Test CLI behavior only
```

The project includes automated tests for:
- Installation script validity and plist configuration
- CLI argument parsing and version output
- Binary integrity and size checks

See [CLAUDE.md](CLAUDE.md) for detailed testing information and development guidelines.

----------------
## Credits

**Original Author**: [Prag Batra (SyntaxSoft)](https://github.com/thesyntaxinator)
**Original Repository**: https://github.com/thesyntaxinator/TouchGuard

This fork adds cursor movement blocking, installation scripts, and LaunchDaemon support for easier deployment. See [CREDITS.md](CREDITS.md) for full attribution.

----------------
## Support

**For this fork**: Open an issue at https://github.com/sirfifer/TouchGuard/issues

**Original project**: https://github.com/thesyntaxinator/TouchGuard/issues or email syntaxsoftsupport@icloud.com

**Original project**: https://github.com/thesyntaxinator/TouchGuard/issues or email syntaxsoftsupport@icloud.com

----------------
## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to submit pull requests, and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for our community standards.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
