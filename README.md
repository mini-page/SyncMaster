# 🚀 SyncMaster

**Advanced File Synchronization Tool for Windows PowerShell**

SyncMaster is a powerful, interactive PowerShell module that wraps Windows Robocopy with an intuitive interface for managing file synchronization, backups, and transfers between local drives, USB devices, and network locations.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey.svg)

## ✨ Features

- 🎯 **Interactive Menu Interface** - Easy-to-use TUI for all operations
- 🔄 **Multiple Sync Modes**:
  - One-Way Sync (PC → USB)
  - Mirror Sync (Exact copy with deletion)
  - Two-Way Sync (Bidirectional)
  - Restore Mode (USB → PC)
- 💾 **Profile Management** - Save and reuse sync configurations
- 🔍 **Auto-Detection** - Automatically detects removable drives
- 📊 **Preview Mode** - See changes before executing
- 📝 **Detailed Logging** - All operations logged automatically
- ⚡ **Multi-threaded** - Fast transfers using parallel copying
- 🛡️ **Safe Operations** - Confirmation prompts for destructive actions
- 📁 **Quick Folders** - One-click access to Documents, Pictures, etc.

## 📋 Requirements

- Windows 10/11 or Windows Server 2016+
- PowerShell 5.1 or higher
- Robocopy (built into Windows)

## 🔧 Installation

### Method 1: Quick Install (Recommended)

1. Download the repository
2. Run the installer:

```powershell
# Run as Administrator (optional, for system-wide install)
.\INSTALL.ps1
```

### Method 2: Manual Install

```powershell
# 1. Create module directory
$modulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\SyncMaster"
New-Item -ItemType Directory -Path $modulePath -Force

# 2. Copy module files
Copy-Item .\SyncMaster.psm1 $modulePath\
Copy-Item .\SyncMaster.psd1 $modulePath\

# 3. Import the module
Import-Module SyncMaster
```

### Method 3: Temporary Use (No Installation)

```powershell
# Import directly from downloaded location
Import-Module .\SyncMaster.psm1
```

## 🚀 Quick Start

### Launch Interactive UI

```powershell
# Start the interactive menu
Start-SyncMasterUI

# Or use the short alias
sync
```

### Command-Line Usage

```powershell
# One-way sync
Start-OneWaySync -Source "C:\Documents" -Destination "E:\Backup"

# Preview before syncing (dry run)
Start-OneWaySync -Source "C:\Documents" -Destination "E:\Backup" -WhatIf

# Mirror sync (deletes files in destination not in source)
Start-MirrorSync -Source "C:\Photos" -Destination "E:\PhotoBackup"

# Two-way sync (bidirectional)
Start-TwoWaySync -Path1 "C:\Work" -Path2 "E:\WorkBackup"

# Restore from backup
Start-RestoreSync -Source "E:\Backup" -Destination "C:\Documents"
```

## 📖 Usage Guide

### Interactive Menu Options

1. **Quick Sync** - Standard one-way copy (PC → USB)
2. **Mirror Sync** - Create exact copy (with file deletion)
3. **Two-Way Sync** - Merge changes from both locations
4. **Restore** - Copy from USB back to PC
5. **Manage Profiles** - Save/load sync configurations
6. **View Logs** - Review operation history
7. **Settings** - Configure advanced options

### Creating a Sync Profile

```powershell
# Save a sync configuration for repeated use
Save-SyncProfile -Name "DailyDocuments" `
                 -Source "C:\Documents" `
                 -Destination "E:\Backup\Documents" `
                 -Type "OneWay"

# Run a saved profile
Invoke-SyncProfile -Name "DailyDocuments"
```

### Advanced Options

```powershell
# Custom exclusions
Start-OneWaySync -Source "C:\Data" -Destination "E:\Backup" `
                 -ExcludeDirs @('temp', 'cache', 'node_modules') `
                 -ExcludeFiles @('*.tmp', '*.log')

# Adjust performance
Start-OneWaySync -Source "C:\Data" -Destination "E:\Backup" `
                 -ThreadCount 16 `
                 -Retries 5 `
                 -WaitTime 10

# Copy all attributes (security, ownership)
Start-OneWaySync -Source "C:\Data" -Destination "E:\Backup" -CopyAll
```

## 🔍 Detecting Drives and Folders

```powershell
# List all removable drives
Get-RemovableDrives

# Get common user folders
Get-LocalFolders

# View all saved profiles
Get-SyncProfiles
```

## 📁 Configuration & Logs

**Configuration Location:**
- Config: `%USERPROFILE%\.syncmaster\profiles.json`
- Logs: `%USERPROFILE%\.syncmaster\logs\`

**Log Files:**
- Named with timestamp: `sync_20241104_143022.log`
- Contains detailed Robocopy output
- Accessible via Settings menu

## 🎯 Use Cases

### Daily Backup to USB Drive

```powershell
# Set up once, run daily
Save-SyncProfile -Name "DailyBackup" `
                 -Source "C:\ImportantFiles" `
                 -Destination "E:\Backup" `
                 -Type "OneWay"

# Quick execution
Invoke-SyncProfile -Name "DailyBackup"
```

### Project Migration

```powershell
# Move entire project with all attributes
Start-OneWaySync -Source "C:\OldProject" `
                 -Destination "D:\NewProject" `
                 -CopyAll
```

### Sync Work Files Between Computers

```powershell
# Two-way sync via USB drive
Start-TwoWaySync -Path1 "C:\WorkFiles" -Path2 "E:\Sync"
# Then on other computer
Start-TwoWaySync -Path1 "C:\WorkFiles" -Path2 "E:\Sync"
```

### Scheduled Backups (Task Scheduler)

```powershell
# Create a scheduled task
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
          -Argument "-Command `"Import-Module SyncMaster; Invoke-SyncProfile -Name 'DailyBackup'`""

$trigger = New-ScheduledTaskTrigger -Daily -At "6:00PM"

Register-ScheduledTask -TaskName "SyncMaster Daily Backup" `
                       -Action $action `
                       -Trigger $trigger `
                       -Description "Automatic daily backup using SyncMaster"
```

## 🛡️ Safety Features

- **Preview Mode**: Always test with `-WhatIf` first
- **Confirmation Prompts**: Destructive operations require explicit confirmation
- **Automatic Logging**: Every operation is logged for audit trails
- **Smart Exclusions**: Automatically skips system files and folders
- **Exit Code Checking**: Validates Robocopy success/failure

## ⚙️ Advanced Configuration

### Custom Robocopy Parameters

The module uses sensible defaults, but you can customize:

```powershell
# Default settings (automatically applied):
# /E            - Copy subdirectories including empty
# /DCOPY:DAT    - Copy directory attributes and timestamps
# /FFT          - FAT file time compatibility
# /R:3 /W:5     - 3 retries with 5 second wait
# /MT:8         - 8 threads for multi-threaded copy
# /NP /NDL      - Minimal console output
```

### Module Auto-Loading

Add to your PowerShell profile for automatic loading:

```powershell
# Edit profile
notepad $PROFILE

# Add this line
Import-Module SyncMaster
```

## 🐛 Troubleshooting

### Module Not Found
```powershell
# Check module path
$env:PSModulePath -split ';'

# Manually import
Import-Module "C:\Path\To\SyncMaster\SyncMaster.psm1"
```

### Permission Denied
```powershell
# Run PowerShell as Administrator
# Or use backup mode for restricted files
Start-OneWaySync -Source "C:\Data" -Destination "E:\Backup" -CopyAll
```

### Robocopy Exit Codes
- **0-7**: Success (various levels of changes)
- **8**: Copy errors occurred
- **16**: Serious errors, no files copied

Check logs in `%USERPROFILE%\.syncmaster\logs\` for details.

## 📚 Command Reference

### Main Functions
- `Start-SyncMasterUI` - Launch interactive menu
- `Start-OneWaySync` - One-way file copy
- `Start-MirrorSync` - Mirror directory (with deletion)
- `Start-TwoWaySync` - Bidirectional sync
- `Start-RestoreSync` - Restore from backup

### Utility Functions
- `Get-RemovableDrives` - Detect USB/external drives
- `Get-LocalFolders` - List common user folders
- `Save-SyncProfile` - Save sync configuration
- `Get-SyncProfiles` - List saved profiles
- `Invoke-SyncProfile` - Run saved profile

### Aliases
- `sync` → `Start-SyncMasterUI`
- `syncui` → `Start-SyncMasterUI`

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built on Windows Robocopy
- Inspired by the need for simpler backup solutions
- Community feedback and contributions

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/SyncMaster/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/SyncMaster/discussions)

## 🗺️ Roadmap

- [ ] PowerShell Gallery publishing
- [ ] GUI version using Windows Forms
- [ ] Cloud storage support (OneDrive, Dropbox)
- [ ] Compression options
- [ ] Email notifications
- [ ] Bandwidth throttling controls

---

**Made with ❤️ for the PowerShell community**
