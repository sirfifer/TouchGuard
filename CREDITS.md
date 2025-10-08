# Credits

## Original Author

**TouchGuard** was originally created by:
- **Author**: Prag Batra (SyntaxSoft)
- **Email**: syntaxsoftsupport@icloud.com
- **GitHub**: [@thesyntaxinator](https://github.com/thesyntaxinator)
- **Original Repository**: https://github.com/thesyntaxinator/TouchGuard
- **Created**: October 2016

## Original Project Description

TouchGuard is a macOS utility that disables the Mac touchpad for a user-specified amount of time each time a key is pressed on the keyboard. This prevents accidental touchpad input (e.g., palm of hand moving over the edge of the touchpad) from being detected as a tap and causing the cursor to jump to a different line while the user is typing.

## This Fork

This fork includes the following enhancements:
- **Cursor movement blocking**: Added `-blockMovement` and `-movementTime` options to also block cursor movement (not just clicks)
- **Installation scripts**: Added `install.sh` and `uninstall.sh` for easy installation as a LaunchDaemon
- **LaunchDaemon support**: Automatic startup on boot with proper configuration
- **Enhanced documentation**: Updated README and added CLAUDE.md for development guidance

**Fork maintained by**: [@sirfifer](https://github.com/sirfifer)
**Fork repository**: https://github.com/sirfifer/TouchGuard

## Acknowledgments

Special thanks to the original author for creating this useful utility and sharing it with the community.
