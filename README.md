# TouchGuard

Disables Mac touchpad for a user-specified amount of time each time a key is pressed on the keyboard. This prevents accidental touchpad input (e.g. palm of hand moving over the edge of the touchpad) from being detected as a tap and causing the cursor to jump to a different line while the user is typing.

**Download latest release from [here](https://github.com/thesyntaxinator/TouchGuard/releases)**

*NOTE: Must be run with administrative privileges.*

----------------
## Quick Install (Recommended)

Download the latest release and run the installer:

```bash
# Navigate to the downloaded folder
cd path/to/TouchGuard

# Run the installer (will prompt for your password)
sudo ./install.sh
```

That's it! TouchGuard is now running and will automatically start every time you boot your Mac.

**To uninstall:**
```bash
sudo ./uninstall.sh
```

**To customize settings** (e.g., change the time interval or enable movement blocking):

Edit `/Library/LaunchDaemons/com.syntaxsoft.touchguard.plist` and modify the `ProgramArguments` section:

```xml
<key>ProgramArguments</key>
<array>
    <string>/usr/local/bin/TouchGuard</string>
    <string>-time</string>
    <string>0.2</string>
    <!-- Optional: Add movement blocking -->
    <string>-blockMovement</string>
    <string>-movementTime</string>
    <string>0.1</string>
</array>
```

Then restart the service:
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

