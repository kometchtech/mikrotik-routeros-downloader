# MikroTik RouterOS Downloader

A PowerShell script for downloading MikroTik RouterOS packages using aria2c for fast parallel downloads.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

English | [日本語](README_ja.md)

## Features

- 🚀 **Fast Parallel Downloads** - Uses aria2c for high-speed multi-connection downloads
- 📦 **Comprehensive Package Coverage** - Downloads all available packages for a version
  - CHR (Cloud Hosted Router) images for x86 and ARM64
  - RouterOS packages for all architectures (x86, ARM, ARM64, MIPSBE, MMIPS, PowerPC, SMIPS, Tile)
  - ISO images
  - Netinstall tools
  - Additional utilities (Dude, bandwidth test, etc.)
- 🔄 **Resume Support** - Automatically resumes interrupted downloads
- ✅ **Version Detection** - Automatically detects RouterOS v6 or v7 and uses appropriate file list
- 🎯 **Simple Usage** - Just specify the version number

## Requirements

- **Windows** with PowerShell 7.5.4 or later
- **aria2c** - Download and install from [https://aria2.github.io/](https://aria2.github.io/)

### Installing aria2c

**Using winget:**
```powershell
winget install aria2.aria2
```

After installation, restart your terminal or PowerShell window to ensure aria2c is available in your PATH.

## Installation

### Method 1: Download File Directly

1. Download `download.ps1` from this repository
2. Place it in your desired folder
3. Done!

### Method 2: Clone Repository

```bash
git clone https://github.com/kometchtech/routeros-downloader.git
cd routeros-downloader
```

## Usage

### Option 1: Bypass Execution Policy (One-time)
```powershell
powershell -ExecutionPolicy Bypass -File .\download.ps1 7.20.6
```

### Option 2: Unblock File (Once)
```powershell
Unblock-File .\download.ps1
.\download.ps1 7.20.6
```

### Option 3: Set Execution Policy (Permanent)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\download.ps1 7.20.6
```

### Examples

**Download RouterOS v7.20.6:**
```powershell
.\download.ps1 7.20.6
```

**Download RouterOS v6.49.19:**
```powershell
.\download.ps1 6.49.19
```

## Output

Files are downloaded to a directory named `routeros-<version>` in the current directory.

Example:
```
./routeros-7.20.6/
├── chr-7.20.6.img.zip
├── chr-7.20.6.vdi.zip
├── routeros-7.20.6.npk
├── mikrotik-7.20.6.iso
├── all_packages-x86-7.20.6.zip
├── all_packages-arm64-7.20.6.zip
└── ... (and many more)
```

## How It Works

1. **Version Detection**: The script automatically detects if you're downloading RouterOS v6 or v7
2. **URL Generation**: Creates a complete list of download URLs based on the version
3. **Parallel Download**: Uses aria2c to download multiple files simultaneously with multiple connections per file
4. **Error Handling**: Some files may not exist for certain versions (404 errors are normal)

### aria2c Parameters Used

- `-c`: Continue partially downloaded files
- `-x6`: Maximum 6 connections per file
- `-s6`: Split each file into 6 pieces
- `-k 1M`: Minimum split size of 1MB
- `-Z`: Download in random order
- `--auto-file-renaming=false`: Don't rename existing files

## Troubleshooting

### "Cannot be loaded" Error

If you see an error like:
```
File cannot be loaded. The file is not digitally signed.
```

**Solution:** Unblock the file
```powershell
Unblock-File .\download.ps1
```

Or use the bypass method:
```powershell
powershell -ExecutionPolicy Bypass -File .\download.ps1 7.20.6
```

### "aria2c not found" Error

aria2c is not installed or not in your system PATH.

**Solution:** Install aria2c using one of the methods in the [Requirements](#requirements) section.

### 404 Errors During Download

Some files may not exist for certain versions (e.g., architecture-specific packages). This is normal and the script will continue downloading available files.

## Architecture Support

### RouterOS v7
- x86 (standard PCs, virtual machines)
- ARM64 (RB5009, CCR2xxx series)
- ARM (older RBxxxxARM devices)
- MIPSBE (older devices)
- MMIPS (older devices)
- PowerPC (older devices)
- SMIPS (older devices)
- Tile (CCR1xxx series)

### RouterOS v6
All architectures except ARM64 ISO

## About

This project is created and maintained by kometchtech from [Routerboard User Group JP](https://rb-ug.jp/).

### Credits

- Based on [mikrotik-routeros-downloader](https://github.com/bajodel/mikrotik-routeros-downloader) by bajodel
- Enhanced with aria2c integration for faster downloads
- Simplified usage with command-line arguments

## License

MIT License

Original work Copyright (c) 2025 bajodel  
Modified work Copyright (c) 2025 Routerboard User Group JP

See [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

## Links

- [MikroTik Official Download Page](https://mikrotik.com/download)
- [RouterOS Documentation](https://help.mikrotik.com/docs/)
- [Routerboard User Group JP](https://rb-ug.jp/)
- [aria2 Official Site](https://aria2.github.io/)

## Support

For issues, questions, or suggestions:
- 🐛 [Open an issue](https://github.com/kometchtech/routeros-downloader/issues)
- 💬 Visit [Routerboard User Group JP](https://rb-ug.jp/)
