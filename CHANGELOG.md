# Changelog

All notable changes to TouchGuard will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.5.0] - 2025-10-07

### Added
- **Cursor movement blocking** - New `-blockMovement` flag to block cursor movement in addition to clicks
- **Configurable movement timeout** - `-movementTime` flag for separate movement blocking duration (defaults to `-time` value)
- **One-command installation** - Quick install via `curl | sudo bash`
- **Automated install/uninstall scripts** - Professional LaunchDaemon setup with auto-start on boot
- **GitHub Actions workflow** - Automated release builds and publishing on version tags
- **Comprehensive test suite** - 19 automated tests covering installation validation and CLI behavior
- **Quick install/uninstall scripts** - `scripts/quick-install.sh` and `scripts/quick-uninstall.sh`
- **Makefile** - Build and test automation with targets for `build`, `test`, `clean`
- **Professional documentation**:
  - `CLAUDE.md` - Development guide with architecture, testing, and release process
  - `CREDITS.md` - Proper attribution to original author
  - Updated README with comprehensive installation guide

### Changed
- Version output format now includes patch version: "TouchGuard v1.5.0"
- README completely overhauled with new installation methods (quick install vs manual)
- Documentation structure improved with clear sections
- Tests updated to verify v1.5.0

### Infrastructure
- Implemented semantic versioning (MAJOR.MINOR.PATCH)
- Automated GitHub releases on version tags (e.g., `v1.5.0`)
- Release packages include binary, scripts, plist, documentation, and SHA256 checksum
- CI/CD pipeline runs tests before releasing

### Technical Details
- Movement blocking intercepts: `kCGEventMouseMoved`, `kCGEventLeftMouseDragged`, `kCGEventRightMouseDragged`, `kCGEventOtherMouseDragged`
- Separate timer callbacks for clicks vs movement for independent timeout control
- LaunchDaemon configuration for system-level service management

## [1.4] - 2016-10-23

### Added
- Initial public release by Prag Batra (SyntaxSoft)
- Basic touchpad click blocking during typing
- Configurable timeout via `-time` flag (in seconds)
- Debug control flags:
  - `-nodebug` - Suppress debug messages
  - `-TapEnableMsg` - Show tap re-enable messages
  - `-TapDisableMsg` - Show tap disable messages
  - `-TapIgnoreMsg` - Show ignored tap messages (enabled by default)
- `-version` flag to display version information
- Event tap using Core Graphics framework
- Grand Central Dispatch (GCD) for timer management
- Support for macOS 10.11+

### Technical Details
- Blocks click events: `kCGEventLeftMouseDown`, `kCGEventLeftMouseUp`, `kCGEventRightMouseDown`, `kCGEventRightMouseUp`
- Uses `CGEventTapCreate` with elevated privileges
- Requires running with `sudo` for system-level event access

---

[1.5.0]: https://github.com/sirfifer/TouchGuard/releases/tag/v1.5.0
[1.4]: https://github.com/thesyntaxinator/TouchGuard/releases/tag/1.4
