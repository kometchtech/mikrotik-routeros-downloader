# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.2] - 2025-12-06

### Fixed
- 🐛 Corrected Routerboard User Group JP URL to `https://www.rb-ug.jp/` in all README files

## [2.1.1] - 2025-12-06

### Removed
- 📝 Removed footer attribution from README files (English and Japanese)

## [2.1.0] - 2025-12-06

### Added
- ✨ Bash version for Linux (Ubuntu/Debian) environments
- 📝 Cross-platform support documentation (Windows PowerShell + Linux Bash)
- 📝 Platform-specific installation instructions (winget for Windows, apt for Linux)

### Changed
- 🔧 PowerShell version requirement updated to 7.5.4 or later
- 🔧 Simplified aria2c installation methods (winget for Windows, apt for Ubuntu/Debian)
- 📝 Repository URL updated to `https://github.com/kometchtech/mikrotik-routeros-downloader`
- 📝 Project title changed to "MikroTik RouterOS Downloader"
- 📝 Description simplified to "packages" (removed "firmware" terminology)
- 📝 Removed macOS support documentation (not tested)
- 📝 Removed support for other Linux distributions (Fedora, RHEL, Arch Linux - not tested)

### Removed
- 🗑️ Batch file (`.bat`) for Windows - direct PowerShell execution recommended
- 🗑️ macOS installation instructions
- 🗑️ Fedora/RHEL/Arch Linux installation instructions

## [2.0.0] - 2025-12-06

### Added
- ✨ aria2c integration for fast parallel downloads with multi-connection support
- ✨ Command-line argument support (e.g., `.\download.ps1 7.20.6`)
- ✨ Automatic resume support for interrupted downloads
- ✨ Comprehensive error handling and user feedback messages
- ✨ Progress indicators and download summary
- 📝 Detailed README documentation in English and Japanese
- 📝 Troubleshooting guide
- 📝 Architecture support reference

### Changed
- 🌐 Full English translation of code comments and messages
- 🔄 Improved script structure with modular functions
- 🎨 Enhanced console output with color-coded messages
- 📦 Updated package list based on latest RouterOS download structure

### Fixed
- 🐛 Better handling of non-existent files (404 errors)
- 🐛 Improved version detection logic

## [1.0.0] - Initial Release

### Added
- Basic download functionality for RouterOS v6 and v7
- Support for multiple architectures
- Simple URL generation

### Credits
- Based on [mikrotik-routeros-downloader](https://github.com/bajodel/mikrotik-routeros-downloader) by bajodel

---

## Legend

- ✨ Added - New features
- 🔄 Changed - Changes in existing functionality
- 🐛 Fixed - Bug fixes
- 🗑️ Removed - Removed features
- 🔒 Security - Security fixes
- 📝 Documentation - Documentation updates
- 🌐 Internationalization - Language/locale updates
- 🎨 Style - Code style/formatting changes
- 📦 Dependencies - Dependency updates
