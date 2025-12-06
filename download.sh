#!/usr/bin/env bash

# MikroTik RouterOS Firmware Downloader Script v2.0
#
# This script downloads RouterOS firmware packages using aria2c for fast parallel downloads.
# Based on: https://github.com/bajodel/mikrotik-routeros-downloader
#
# Original work Copyright (c) 2025 bajodel (MIT License)
# Modified work Copyright (c) 2025 Routerboard User Group JP
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Usage: ./download.sh <version>
# Examples:
#   ./download.sh 7.20.6
#   ./download.sh 6.49.19
#
# Features:
# - Supports both RouterOS v6 and v7
# - Fast parallel downloads using aria2c
# - Comprehensive download including CHR, ISO, packages, Netinstall, etc.
#
# Requirements:
# - aria2c (https://aria2.github.io/)

set -euo pipefail

# Color definitions
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_WHITE='\033[1;37m'
readonly COLOR_RESET='\033[0m'

# Print colored message
print_message() {
    local color=$1
    shift
    echo -e "${color}$*${COLOR_RESET}"
}

# Show usage information
show_usage() {
    print_message "${COLOR_CYAN}" "RouterOS Firmware Downloader Script"
    echo ""
    print_message "${COLOR_YELLOW}" "Usage:"
    print_message "${COLOR_WHITE}" "  ./download.sh <version>"
    echo ""
    print_message "${COLOR_YELLOW}" "Examples:"
    print_message "${COLOR_WHITE}" "  ./download.sh 7.20.6"
    print_message "${COLOR_WHITE}" "  ./download.sh 6.49.19"
    echo ""
    print_message "${COLOR_YELLOW}" "Note: aria2c must be installed"
    exit 1
}

# Check if aria2c is installed
check_aria2_installed() {
    if ! command -v aria2c &> /dev/null; then
        print_message "${COLOR_RED}" "ERROR: aria2c not found."
        print_message "${COLOR_YELLOW}" "Please install aria2c:"
        echo "  Ubuntu/Debian: sudo apt install aria2"
        exit 1
    fi
}

# Initialize download directory
initialize_download_directory() {
    local dir_path=$1
    
    if [ ! -d "$dir_path" ]; then
        mkdir -p "$dir_path"
        print_message "${COLOR_GREEN}" "Created download directory: $dir_path"
    fi
}

# Get download URLs based on version
get_download_urls() {
    local base_url=$1
    local version=$2
    local -n urls=$3
    
    if [[ $version =~ ^6 ]]; then
        print_message "${COLOR_CYAN}" "Detected RouterOS v6. Using v6 URL list."
        urls=(
            # CHR (Cloud Hosted Router) - x86 only
            "$base_url/chr-$version.img.zip"
            "$base_url/chr-$version.vdi.zip"
            "$base_url/chr-$version.vhdx.zip"
            "$base_url/chr-$version.ova"
            "$base_url/chr-$version.vhd.zip"
            "$base_url/chr-$version.vmdk.zip"
            
            # x86 RouterOS
            "$base_url/routeros-x86-$version.npk"
            "$base_url/mikrotik-$version.iso"
            "$base_url/install-image-$version.zip"
            "$base_url/all_packages-x86-$version.zip"
            
            # ARM64
            "$base_url/routeros-arm64-$version.npk"
            "$base_url/all_packages-arm64-$version.zip"
            
            # ARM
            "$base_url/routeros-arm-$version.npk"
            "$base_url/all_packages-arm-$version.zip"
            
            # MIPSBE
            "$base_url/routeros-mipsbe-$version.npk"
            "$base_url/all_packages-mipsbe-$version.zip"
            
            # MMIPS
            "$base_url/routeros-mmips-$version.npk"
            "$base_url/all_packages-mmips-$version.zip"
            
            # PowerPC
            "$base_url/routeros-powerpc-$version.npk"
            "$base_url/all_packages-ppc-$version.zip"
            
            # SMIPS
            "$base_url/routeros-smips-$version.npk"
            "$base_url/all_packages-smips-$version.zip"
            
            # Tile
            "$base_url/routeros-tile-$version.npk"
            "$base_url/all_packages-tile-$version.zip"
            
            # Netinstall
            "$base_url/netinstall64-$version.zip"
            "$base_url/netinstall-$version.zip"
            "$base_url/netinstall-$version.tar.gz"
            
            # Miscellaneous
            "$base_url/mikrotik.mib"
            "$base_url/dude-install-$version.exe"
            "$base_url/btest.exe"
            "$base_url/flashfig.exe"
        )
    elif [[ $version =~ ^7 ]]; then
        print_message "${COLOR_CYAN}" "Detected RouterOS v7. Using v7 URL list."
        urls=(
            # CHR (Cloud Hosted Router) - x86
            "$base_url/chr-$version.img.zip"
            "$base_url/chr-$version.vdi.zip"
            "$base_url/chr-$version.vhdx.zip"
            "$base_url/chr-$version.ova"
            "$base_url/chr-$version.vhd.zip"
            "$base_url/chr-$version.vmdk.zip"
            
            # CHR (Cloud Hosted Router) - ARM64
            "$base_url/chr-$version-arm64.img.zip"
            "$base_url/chr-$version-arm64.vdi.zip"
            
            # x86 RouterOS
            "$base_url/routeros-$version.npk"
            "$base_url/mikrotik-$version.iso"
            "$base_url/install-image-$version.zip"
            "$base_url/all_packages-x86-$version.zip"
            
            # ARM64
            "$base_url/routeros-$version-arm64.npk"
            "$base_url/mikrotik-$version-arm64.iso"
            "$base_url/all_packages-arm64-$version.zip"
            
            # ARM
            "$base_url/routeros-$version-arm.npk"
            "$base_url/all_packages-arm-$version.zip"
            
            # MIPSBE
            "$base_url/routeros-$version-mipsbe.npk"
            "$base_url/all_packages-mipsbe-$version.zip"
            
            # MMIPS
            "$base_url/routeros-$version-mmips.npk"
            "$base_url/all_packages-mmips-$version.zip"
            
            # PowerPC
            "$base_url/routeros-$version-ppc.npk"
            "$base_url/all_packages-ppc-$version.zip"
            
            # SMIPS
            "$base_url/routeros-$version-smips.npk"
            "$base_url/all_packages-smips-$version.zip"
            
            # Tile
            "$base_url/routeros-$version-tile.npk"
            "$base_url/all_packages-tile-$version.zip"
            
            # Netinstall
            "$base_url/netinstall64-$version.zip"
            "$base_url/netinstall-$version.zip"
            "$base_url/netinstall-$version.tar.gz"
            
            # Miscellaneous
            "$base_url/mikrotik.mib"
            "$base_url/dude-install-$version.exe"
            "$base_url/btest.exe"
            "$base_url/flashfig.exe"
        )
    else
        print_message "${COLOR_RED}" "ERROR: Only RouterOS v6 or v7 is supported."
        print_message "${COLOR_YELLOW}" "Specified version: $version"
        exit 1
    fi
}

# Start aria2c download
start_aria2_download() {
    local destination_dir=$1
    shift
    local urls=("$@")
    
    local temp_file
    temp_file=$(mktemp)
    
    # Write URLs to temp file
    printf "%s\n" "${urls[@]}" > "$temp_file"
    
    echo ""
    print_message "${COLOR_CYAN}" "================================================"
    print_message "${COLOR_CYAN}" "Starting parallel download"
    print_message "${COLOR_CYAN}" "================================================"
    print_message "${COLOR_WHITE}" "Total files: ${#urls[@]}"
    print_message "${COLOR_WHITE}" "Destination: $destination_dir"
    echo ""
    
    # aria2c parameters:
    # -c: Continue downloading partially downloaded files
    # -x6: Maximum 6 connections per file
    # -s6: Split file into 6 pieces for download
    # -k 1M: Minimum split size of 1MB per connection
    # -Z: Download files in random order from input file
    # -d: Download destination directory
    # -i: Input file (URL list)
    # --auto-file-renaming=false: Don't rename files automatically if they exist
    aria2c -c -x6 -s6 -k 1M -Z --auto-file-renaming=false -d "$destination_dir" -i "$temp_file"
    
    local exit_code=$?
    
    echo ""
    print_message "${COLOR_CYAN}" "================================================"
    if [ $exit_code -eq 0 ]; then
        print_message "${COLOR_GREEN}" "All files downloaded successfully."
    else
        print_message "${COLOR_YELLOW}" "Some files failed to download."
        print_message "${COLOR_YELLOW}" "Exit code: $exit_code"
        echo ""
        print_message "${COLOR_YELLOW}" "Note: Files that don't exist (architecture-specific packages, etc.)"
        print_message "${COLOR_YELLOW}" "      will result in 404 errors, which is normal."
    fi
    print_message "${COLOR_CYAN}" "================================================"
    
    # Clean up temp file
    rm -f "$temp_file"
}

# Main function
main() {
    # Check if version argument is provided
    if [ $# -eq 0 ]; then
        show_usage
    fi
    
    local version=$1
    
    # Check if aria2c is installed
    check_aria2_installed
    
    local download_dir="./routeros-$version"
    local base_url="https://download.mikrotik.com/routeros/$version"
    
    echo ""
    print_message "${COLOR_CYAN}" "================================================"
    print_message "${COLOR_CYAN}" "RouterOS Firmware Downloader Script v2.0"
    print_message "${COLOR_CYAN}" "================================================"
    print_message "${COLOR_WHITE}" "Version: $version"
    print_message "${COLOR_WHITE}" "Download URL: $base_url"
    echo ""
    
    # Create download directory
    initialize_download_directory "$download_dir"
    
    # Get list of URLs to download
    local urls=()
    get_download_urls "$base_url" "$version" urls
    
    # Execute download
    start_aria2_download "$download_dir" "${urls[@]}"
    
    echo ""
    print_message "${COLOR_GREEN}" "Download completed."
    print_message "${COLOR_WHITE}" "Files saved to: $(cd "$download_dir" && pwd)"
    echo ""
}

# Execute script
main "$@"
