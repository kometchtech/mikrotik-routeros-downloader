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
# Usage: .\download.ps1 <version>
# Examples:
#   .\download.ps1 7.20.6
#   .\download.ps1 6.49.19
#
# Features:
# - Supports both RouterOS v6 and v7
# - Fast parallel downloads using aria2c
# - Comprehensive download including CHR, ISO, packages, Netinstall, etc.
#
# Requirements:
# - aria2c (https://aria2.github.io/)

Param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Version
)

function Show-Usage {
    Write-Host "RouterOS Firmware Downloader Script" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\download.ps1 <version>" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\download.ps1 7.20.6" -ForegroundColor White
    Write-Host "  .\download.ps1 6.49.19" -ForegroundColor White
    Write-Host ""
    Write-Host "Note: aria2c must be installed" -ForegroundColor Yellow
    exit 1
}

function Test-Aria2Installed {
    try {
        $null = Get-Command aria2c -ErrorAction Stop
        return $true
    }
    catch {
        Write-Host "ERROR: aria2c not found." -ForegroundColor Red
        Write-Host "Please install aria2c: https://aria2.github.io/" -ForegroundColor Yellow
        exit 1
    }
}

function Initialize-DownloadDirectory {
    param (
        [string]$DirectoryPath
    )
    
    if (-not (Test-Path $DirectoryPath)) {
        New-Item -ItemType Directory -Path $DirectoryPath | Out-Null
        Write-Host "Created download directory: $DirectoryPath" -ForegroundColor Green
    }
}

function Get-DownloadUrls {
    param (
        [string]$BaseUrl,
        [string]$Version
    )
    
    $urls = @()
    
    if ($Version -match '^6') {
        Write-Host "Detected RouterOS v6. Using v6 URL list." -ForegroundColor Cyan
        $urls = @(
            # CHR (Cloud Hosted Router) - x86 only
            "$BaseUrl/chr-$Version.img.zip",
            "$BaseUrl/chr-$Version.vdi.zip",
            "$BaseUrl/chr-$Version.vhdx.zip",
            "$BaseUrl/chr-$Version.ova",
            "$BaseUrl/chr-$Version.vhd.zip",
            "$BaseUrl/chr-$Version.vmdk.zip",
            
            # x86 RouterOS
            "$BaseUrl/routeros-x86-$Version.npk",
            "$BaseUrl/mikrotik-$Version.iso",
            "$BaseUrl/install-image-$Version.zip",
            "$BaseUrl/all_packages-x86-$Version.zip",
            
            # ARM64
            "$BaseUrl/routeros-arm64-$Version.npk",
            "$BaseUrl/all_packages-arm64-$Version.zip",
            
            # ARM
            "$BaseUrl/routeros-arm-$Version.npk",
            "$BaseUrl/all_packages-arm-$Version.zip",
            
            # MIPSBE
            "$BaseUrl/routeros-mipsbe-$Version.npk",
            "$BaseUrl/all_packages-mipsbe-$Version.zip",
            
            # MMIPS
            "$BaseUrl/routeros-mmips-$Version.npk",
            "$BaseUrl/all_packages-mmips-$Version.zip",
            
            # PowerPC
            "$BaseUrl/routeros-powerpc-$Version.npk",
            "$BaseUrl/all_packages-ppc-$Version.zip",
            
            # SMIPS
            "$BaseUrl/routeros-smips-$Version.npk",
            "$BaseUrl/all_packages-smips-$Version.zip",
            
            # Tile
            "$BaseUrl/routeros-tile-$Version.npk",
            "$BaseUrl/all_packages-tile-$Version.zip",
            
            # Netinstall
            "$BaseUrl/netinstall64-$Version.zip",
            "$BaseUrl/netinstall-$Version.zip",
            "$BaseUrl/netinstall-$Version.tar.gz",
            
            # Miscellaneous
            "$BaseUrl/mikrotik.mib",
            "$BaseUrl/dude-install-$Version.exe",
            "$BaseUrl/btest.exe",
            "$BaseUrl/flashfig.exe"
        )
    }
    elseif ($Version -match '^7') {
        Write-Host "Detected RouterOS v7. Using v7 URL list." -ForegroundColor Cyan
        $urls = @(
            # CHR (Cloud Hosted Router) - x86
            "$BaseUrl/chr-$Version.img.zip",
            "$BaseUrl/chr-$Version.vdi.zip",
            "$BaseUrl/chr-$Version.vhdx.zip",
            "$BaseUrl/chr-$Version.ova",
            "$BaseUrl/chr-$Version.vhd.zip",
            "$BaseUrl/chr-$Version.vmdk.zip",
            
            # CHR (Cloud Hosted Router) - ARM64
            "$BaseUrl/chr-$Version-arm64.img.zip",
            "$BaseUrl/chr-$Version-arm64.vdi.zip",
            
            # x86 RouterOS
            "$BaseUrl/routeros-$Version.npk",
            "$BaseUrl/mikrotik-$Version.iso",
            "$BaseUrl/install-image-$Version.zip",
            "$BaseUrl/all_packages-x86-$Version.zip",
            
            # ARM64
            "$BaseUrl/routeros-$Version-arm64.npk",
            "$BaseUrl/mikrotik-$Version-arm64.iso",
            "$BaseUrl/all_packages-arm64-$Version.zip",
            
            # ARM
            "$BaseUrl/routeros-$Version-arm.npk",
            "$BaseUrl/all_packages-arm-$Version.zip",
            
            # MIPSBE
            "$BaseUrl/routeros-$Version-mipsbe.npk",
            "$BaseUrl/all_packages-mipsbe-$Version.zip",
            
            # MMIPS
            "$BaseUrl/routeros-$Version-mmips.npk",
            "$BaseUrl/all_packages-mmips-$Version.zip",
            
            # PowerPC
            "$BaseUrl/routeros-$Version-ppc.npk",
            "$BaseUrl/all_packages-ppc-$Version.zip",
            
            # SMIPS
            "$BaseUrl/routeros-$Version-smips.npk",
            "$BaseUrl/all_packages-smips-$Version.zip",
            
            # Tile
            "$BaseUrl/routeros-$Version-tile.npk",
            "$BaseUrl/all_packages-tile-$Version.zip",
            
            # Netinstall
            "$BaseUrl/netinstall64-$Version.zip",
            "$BaseUrl/netinstall-$Version.zip",
            "$BaseUrl/netinstall-$Version.tar.gz",
            
            # Miscellaneous
            "$BaseUrl/mikrotik.mib",
            "$BaseUrl/dude-install-$Version.exe",
            "$BaseUrl/btest.exe",
            "$BaseUrl/flashfig.exe"
        )
    }
    else {
        Write-Host "ERROR: Only RouterOS v6 or v7 is supported." -ForegroundColor Red
        Write-Host "Specified version: $Version" -ForegroundColor Yellow
        exit 1
    }
    
    return $urls
}

function Start-Aria2Download {
    param (
        [string[]]$Urls,
        [string]$DestinationDir
    )
    
    $tempFile = [System.IO.Path]::GetTempFileName()
    $Urls | Out-File -FilePath $tempFile -Encoding ASCII
    
    try {
        Write-Host ""
        Write-Host "================================================" -ForegroundColor Cyan
        Write-Host "Starting parallel download" -ForegroundColor Cyan
        Write-Host "================================================" -ForegroundColor Cyan
        Write-Host "Total files: $($Urls.Count)" -ForegroundColor White
        Write-Host "Destination: $DestinationDir" -ForegroundColor White
        Write-Host ""
        
        # aria2c parameters:
        # -c: Continue downloading partially downloaded files
        # -x6: Maximum 6 connections per file
        # -s6: Split file into 6 pieces for download
        # -k 1M: Minimum split size of 1MB per connection
        # -Z: Download files in random order from input file
        # -d: Download destination directory
        # -i: Input file (URL list)
        # --auto-file-renaming=false: Don't rename files automatically if they exist
        & aria2c -c -x6 -s6 -k 1M -Z --auto-file-renaming=false -d $DestinationDir -i $tempFile
        
        Write-Host ""
        Write-Host "================================================" -ForegroundColor Cyan
        if ($LASTEXITCODE -eq 0) {
            Write-Host "All files downloaded successfully." -ForegroundColor Green
        }
        else {
            Write-Host "Some files failed to download." -ForegroundColor Yellow
            Write-Host "Exit code: $LASTEXITCODE" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Note: Files that don't exist (architecture-specific packages, etc.)" -ForegroundColor Yellow
            Write-Host "      will result in 404 errors, which is normal." -ForegroundColor Yellow
        }
        Write-Host "================================================" -ForegroundColor Cyan
    }
    catch {
        Write-Host "An error occurred: $_" -ForegroundColor Red
    }
    finally {
        Remove-Item $tempFile -ErrorAction SilentlyContinue
    }
}

# Main processing
function Main {
    # Validate version parameter
    if (-not $Version) {
        Show-Usage
    }
    
    # Check if aria2c is installed
    Test-Aria2Installed
    
    $downloadDir = "./routeros-$Version"
    $baseUrl = "https://download.mikrotik.com/routeros/$Version"
    
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "RouterOS Firmware Downloader Script v2.0" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "Version: $Version" -ForegroundColor White
    Write-Host "Download URL: $baseUrl" -ForegroundColor White
    Write-Host ""
    
    # Create download directory
    Initialize-DownloadDirectory -DirectoryPath $downloadDir
    
    # Get list of URLs to download
    $urls = Get-DownloadUrls -BaseUrl $baseUrl -Version $Version
    
    # Execute download
    Start-Aria2Download -Urls $urls -DestinationDir $downloadDir
    
    Write-Host ""
    Write-Host "Download completed." -ForegroundColor Green
    Write-Host "Files saved to: $(Resolve-Path $downloadDir)" -ForegroundColor White
    Write-Host ""
}

# Execute script
Main
