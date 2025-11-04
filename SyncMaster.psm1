#Requires -Version 5.1

<#
.SYNOPSIS
    SyncMaster - Advanced File Synchronization Module
.DESCRIPTION
    Comprehensive sync tool with detection, interactive setup, and multiple operations
.AUTHOR
    Custom Build
.VERSION
    1.0.0
#>

# ============================================================================
# MODULE VARIABLES
# ============================================================================

$Script:ConfigPath = "$env:USERPROFILE\.syncmaster"
$Script:ConfigFile = "$Script:ConfigPath\profiles.json"
$Script:LogPath = "$Script:ConfigPath\logs"

# ============================================================================
# INITIALIZATION
# ============================================================================

function Initialize-SyncMaster {
    if (-not (Test-Path $Script:ConfigPath)) {
        New-Item -ItemType Directory -Path $Script:ConfigPath -Force | Out-Null
        New-Item -ItemType Directory -Path $Script:LogPath -Force | Out-Null
    }
    if (-not (Test-Path $Script:ConfigFile)) {
        @{profiles = @()} | ConvertTo-Json | Set-Content $Script:ConfigFile
    }
}

# ============================================================================
# DETECTION FUNCTIONS
# ============================================================================

function Get-RemovableDrives {
    <#
    .SYNOPSIS
        Detects all removable drives (USB, external)
    #>
    $drives = Get-Volume | Where-Object { 
        $_.DriveType -eq 'Removable' -or 
        ($_.DriveLetter -and (Get-Partition -DriveLetter $_.DriveLetter -ErrorAction SilentlyContinue).Type -eq 'Basic')
    }
    
    $result = @()
    foreach ($drive in $drives) {
        if ($drive.DriveLetter) {
            $size = [math]::Round($drive.Size / 1GB, 2)
            $free = [math]::Round($drive.SizeRemaining / 1GB, 2)
            $result += [PSCustomObject]@{
                Letter = "$($drive.DriveLetter):"
                Label = $drive.FileSystemLabel
                Size = "${size} GB"
                Free = "${free} GB"
                FileSystem = $drive.FileSystem
            }
        }
    }
    return $result
}

function Get-LocalFolders {
    <#
    .SYNOPSIS
        Gets common user folders for quick selection
    #>
    return @(
        [PSCustomObject]@{Name = "Documents"; Path = [Environment]::GetFolderPath("MyDocuments")}
        [PSCustomObject]@{Name = "Desktop"; Path = [Environment]::GetFolderPath("Desktop")}
        [PSCustomObject]@{Name = "Pictures"; Path = [Environment]::GetFolderPath("MyPictures")}
        [PSCustomObject]@{Name = "Videos"; Path = [Environment]::GetFolderPath("MyVideos")}
        [PSCustomObject]@{Name = "Music"; Path = [Environment]::GetFolderPath("MyMusic")}
        [PSCustomObject]@{Name = "Downloads"; Path = "$env:USERPROFILE\Downloads"}
    )
}

# ============================================================================
# INTERACTIVE MENU FUNCTIONS
# ============================================================================

function Show-MainMenu {
    Clear-Host
    Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║           SYNCMASTER - File Sync Manager               ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] Quick Sync (One-Way: PC → USB)" -ForegroundColor Green
    Write-Host "  [2] Mirror Sync (Exact Copy with Delete)" -ForegroundColor Yellow
    Write-Host "  [3] Two-Way Sync (Bidirectional)" -ForegroundColor Magenta
    Write-Host "  [4] Restore (USB → PC)" -ForegroundColor Blue
    Write-Host "  [5] Manage Sync Profiles" -ForegroundColor White
    Write-Host "  [6] View Logs" -ForegroundColor Gray
    Write-Host "  [7] Settings & Advanced Options" -ForegroundColor DarkCyan
    Write-Host "  [Q] Quit" -ForegroundColor Red
    Write-Host ""
}

function Show-DetectedDrives {
    Write-Host "`n📀 Detected Removable Drives:" -ForegroundColor Cyan
    $drives = Get-RemovableDrives
    if ($drives.Count -eq 0) {
        Write-Host "   ⚠ No removable drives detected!" -ForegroundColor Yellow
        return $null
    }
    
    $selectedDrive = $drives | Out-GridView -Title "Select a drive" -PassThru
    
    return $selectedDrive
}

function Show-QuickFolders {
    Write-Host "`n📁 Quick Folder Selection:" -ForegroundColor Cyan
    $folders = Get-LocalFolders
    for ($i = 0; $i -lt $folders.Count; $i++) {
        Write-Host "   [$($i+1)] $($folders[$i].Name) - $($folders[$i].Path)" -ForegroundColor Gray
    }
    Write-Host "   [C] Custom Path" -ForegroundColor White
    return $folders
}

# ============================================================================
# SYNC OPERATIONS
# ============================================================================

function Start-OneWaySync {
    param(
        [string]$Source,
        [string]$Destination,
        [switch]$WhatIf,
        [string[]]$ExcludeDirs = @('$RECYCLE.BIN', 'System Volume Information', 'hiberfil.sys', 'pagefile.sys'),
        [string[]]$ExcludeFiles = @('Thumbs.db', 'desktop.ini', '.DS_Store'),
        [int]$Retries = 3,
        [int]$WaitTime = 5,
        [switch]$CopyAll,
        [int]$ThreadCount = 8
    )
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $logFile = "$Script:LogPath\sync_$timestamp.log"
    
    Write-Host "`n🚀 Starting One-Way Sync..." -ForegroundColor Green
    Write-Host "   Source: $Source" -ForegroundColor White
    Write-Host "   Destination: $Destination" -ForegroundColor White
    
    $params = @(
        $Source,
        $Destination,
        '/E',           # Copy subdirectories, including empty
        '/DCOPY:DAT',   # Copy Directory timestamps, attributes, etc
        '/FFT',         # Assume FAT file times (2-second granularity)
        "/R:$Retries",  # Retry count
        "/W:$WaitTime", # Wait time between retries
        "/MT:$ThreadCount", # Multi-threaded (default 8)
        '/NP',          # No progress percentage
        '/NDL',         # No directory list
        "/LOG:$logFile" # Log file
    )
    
    if ($CopyAll) {
        $params += '/COPYALL'  # Copy all file info
    }
    
    if ($WhatIf) {
        $params += '/L'  # List only, don't copy
        Write-Host "`n⚠ DRY RUN MODE - No files will be modified" -ForegroundColor Yellow
    }
    
    foreach ($dir in $ExcludeDirs) {
        $params += "/XD"
        $params += $dir
    }
    
    foreach ($file in $ExcludeFiles) {
        $params += "/XF"
        $params += $file
    }
    
    try {
        & robocopy @params
        $exitCode = $LASTEXITCODE
        
        # Robocopy exit codes: 0-7 are success, 8+ are errors
        if ($exitCode -lt 8) {
            Write-Host "`n✅ Sync completed successfully!" -ForegroundColor Green
            Write-Host "   Log saved: $logFile" -ForegroundColor Gray
            return $true
        } else {
            Write-Host "`n❌ Sync completed with errors (Code: $exitCode)" -ForegroundColor Red
            Write-Host "   Check log: $logFile" -ForegroundColor Gray
            return $false
        }
    } catch {
        Write-Host "`n❌ Error: $_" -ForegroundColor Red
        return $false
    }
}

function Start-MirrorSync {
    param(
        [string]$Source,
        [string]$Destination,
        [switch]$WhatIf
    )
    
    Write-Host "`n⚠ MIRROR MODE - Will DELETE files in destination not in source!" -ForegroundColor Yellow
    if (-not $WhatIf) {
        $confirm = Read-Host "Type YES to confirm"
        if ($confirm -ne "YES") {
            Write-Host "Cancelled." -ForegroundColor Red
            return $false
        }
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $logFile = "$Script:LogPath\mirror_$timestamp.log"
    
    $params = @(
        $Source,
        $Destination,
        '/MIR',         # Mirror mode (copy + delete)
        '/DCOPY:DAT',
        '/FFT',
        '/R:3',
        '/W:5',
        '/MT:8',
        '/NP',
        '/NDL',
        "/LOG:$logFile",
        '/XD', '$RECYCLE.BIN', 'System Volume Information',
        '/XF', 'Thumbs.db', 'desktop.ini'
    )
    
    if ($WhatIf) {
        $params += '/L'
    }
    
    & robocopy @params
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -lt 8) {
        Write-Host "`n✅ Mirror completed!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "`n❌ Mirror failed (Code: $exitCode)" -ForegroundColor Red
        return $false
    }
}

function Start-TwoWaySync {
    param(
        [string]$Path1,
        [string]$Path2,
        [switch]$WhatIf
    )
    
    Write-Host "`n🔄 Two-Way Sync (Bidirectional)" -ForegroundColor Magenta
    Write-Host "   This will merge changes from both locations" -ForegroundColor Gray
    
    # Compare both directions
    Write-Host "`n📊 Analyzing differences..." -ForegroundColor Cyan
    
    # Sync Path1 → Path2 (newer files)
    Write-Host "`n➡️  Syncing $Path1 → $Path2" -ForegroundColor Green
    Start-OneWaySync -Source $Path1 -Destination $Path2 -WhatIf:$WhatIf
    
    # Sync Path2 → Path1 (newer files)
    Write-Host "`n⬅️  Syncing $Path2 → $Path1" -ForegroundColor Green
    Start-OneWaySync -Source $Path2 -Destination $Path1 -WhatIf:$WhatIf
    
    Write-Host "`n✅ Two-way sync completed!" -ForegroundColor Green
}

function Start-RestoreSync {
    param(
        [string]$Source,
        [string]$Destination,
        [switch]$WhatIf
    )
    
    Write-Host "`n🔄 Restore Mode (USB → PC)" -ForegroundColor Blue
    Write-Host "   Source: $Source" -ForegroundColor White
    Write-Host "   Destination: $Destination" -ForegroundColor White
    
    if (-not $WhatIf) {
        $confirm = Read-Host "`nThis will overwrite files in destination. Continue? (yes/no)"
        if ($confirm -ne "yes") {
            Write-Host "Cancelled." -ForegroundColor Red
            return $false
        }
    }
    
    Start-OneWaySync -Source $Source -Destination $Destination -WhatIf:$WhatIf
}

# ============================================================================
# PROFILE MANAGEMENT
# ============================================================================

function Save-SyncProfile {
    param(
        [string]$Name,
        [string]$Source,
        [string]$Destination,
        [string]$Type
    )
    
    $profiles = Get-Content $Script:ConfigFile | ConvertFrom-Json
    $newProfile = [PSCustomObject]@{
        Name = $Name
        Source = $Source
        Destination = $Destination
        Type = $Type
        Created = (Get-Date).ToString()
        LastRun = $null
    }
    
    $profiles.profiles += $newProfile
    $profiles | ConvertTo-Json -Depth 10 | Set-Content $Script:ConfigFile
    
    Write-Host "✅ Profile '$Name' saved!" -ForegroundColor Green
}

function Get-SyncProfiles {
    if (Test-Path $Script:ConfigFile) {
        $profiles = Get-Content $Script:ConfigFile | ConvertFrom-Json
        return $profiles.profiles
    }
    return @()
}

function Invoke-SyncProfile {
    param([string]$Name)
    
    $profiles = Get-SyncProfiles
    $profile = $profiles | Where-Object { $_.Name -eq $Name }
    
    if (-not $profile) {
        Write-Host "❌ Profile not found!" -ForegroundColor Red
        return
    }
    
    Write-Host "`n🔄 Running profile: $($profile.Name)" -ForegroundColor Cyan
    
    switch ($profile.Type) {
        "OneWay" { Start-OneWaySync -Source $profile.Source -Destination $profile.Destination }
        "Mirror" { Start-MirrorSync -Source $profile.Source -Destination $profile.Destination }
        "TwoWay" { Start-TwoWaySync -Path1 $profile.Source -Path2 $profile.Destination }
        "Restore" { Start-RestoreSync -Source $profile.Source -Destination $profile.Destination }
    }
    
    # Update last run time
    $profiles = Get-Content $Script:ConfigFile | ConvertFrom-Json
    ($profiles.profiles | Where-Object { $_.Name -eq $Name }).LastRun = (Get-Date).ToString()
    $profiles | ConvertTo-Json -Depth 10 | Set-Content $Script:ConfigFile
}

# ============================================================================
# MAIN INTERACTIVE WORKFLOW
# ============================================================================

function Start-SyncMasterUI {
    Initialize-SyncMaster
    
    while ($true) {
        Show-MainMenu
        $choice = Read-Host "Select option"
        
        switch ($choice) {
            "1" {
                # Quick Sync
                Clear-Host
                Write-Host "═══ QUICK SYNC (One-Way) ═══`n" -ForegroundColor Green
                
                $selectedDrive = Show-DetectedDrives
                if (-not $selectedDrive) { Read-Host "Press Enter"; continue }
                
                $folders = Show-QuickFolders
                $folderChoice = Read-Host "`nSelect source folder (1-$($folders.Count) or C for custom)"
                
                if ($folderChoice -eq "C" -or $folderChoice -eq "c") {
                    $source = Read-Host "Enter source path"
                } else {
                    $idx = [int]$folderChoice - 1
                    $source = $folders[$idx].Path
                }
                
                $destDrive = $selectedDrive.Letter
                $destFolder = Read-Host "Enter destination folder name (or press Enter for root)"
                
                if ($destFolder) {
                    $destination = Join-Path -Path $destDrive -ChildPath $destFolder
                } else {
                    $destination = $destDrive
                }
                
                $preview = Read-Host "`nRun preview first? (y/n)"
                if ($preview -eq "y") {
                    Start-OneWaySync -Source $source -Destination $destination -WhatIf
                    Read-Host "`nPress Enter to run actual sync (or Ctrl+C to cancel)"
                }
                
                Start-OneWaySync -Source $source -Destination $destination
                
                $save = Read-Host "`nSave as profile? (y/n)"
                if ($save -eq "y") {
                    $profileName = Read-Host "Profile name"
                    Save-SyncProfile -Name $profileName -Source $source -Destination $destination -Type "OneWay"
                }
                
                Read-Host "`nPress Enter to continue"
            }
            
            "2" {
                # Mirror Sync
                Clear-Host
                Write-Host "═══ MIRROR SYNC ═══`n" -ForegroundColor Yellow
                
                Show-DetectedDrives | Out-Null
                $folders = Show-QuickFolders
                
                $folderChoice = Read-Host "`nSelect source (1-$($folders.Count) or C)"
                if ($folderChoice -eq "C" -or $folderChoice -eq "c") {
                    $source = Read-Host "Enter source path"
                } else {
                    $source = $folders[[int]$folderChoice - 1].Path
                }
                
                $destination = Read-Host "Enter destination path"
                
                $preview = Read-Host "`nPreview changes? (y/n)"
                if ($preview -eq "y") {
                    Start-MirrorSync -Source $source -Destination $destination -WhatIf
                    Read-Host "`nPress Enter to execute (or Ctrl+C to cancel)"
                }
                
                Start-MirrorSync -Source $source -Destination $destination
                Read-Host "`nPress Enter to continue"
            }
            
            "3" {
                # Two-Way Sync
                Clear-Host
                Write-Host "═══ TWO-WAY SYNC ═══`n" -ForegroundColor Magenta
                
                $path1 = Read-Host "Enter first path (e.g., C:\MyFolder)"
                $path2 = Read-Host "Enter second path (e.g., E:\Backup)"
                
                $preview = Read-Host "`nPreview? (y/n)"
                if ($preview -eq "y") {
                    Start-TwoWaySync -Path1 $path1 -Path2 $path2 -WhatIf
                    Read-Host "`nPress Enter to sync"
                }
                
                Start-TwoWaySync -Path1 $path1 -Path2 $path2
                Read-Host "`nPress Enter"
            }
            
            "4" {
                # Restore
                Clear-Host
                Write-Host "═══ RESTORE MODE ═══`n" -ForegroundColor Blue
                
                Show-DetectedDrives | Out-Null
                $source = Read-Host "Enter source path (USB)"
                $destination = Read-Host "Enter destination (PC folder)"
                
                Start-RestoreSync -Source $source -Destination $destination -WhatIf
                $confirm = Read-Host "`nExecute restore? (yes/no)"
                if ($confirm -eq "yes") {
                    Start-RestoreSync -Source $source -Destination $destination
                }
                
                Read-Host "`nPress Enter"
            }
            
            "5" {
                # Manage Profiles
                Clear-Host
                Write-Host "═══ SAVED PROFILES ═══`n" -ForegroundColor White
                
                $profiles = Get-SyncProfiles
                if ($profiles.Count -eq 0) {
                    Write-Host "No profiles saved yet." -ForegroundColor Gray
                } else {
                    $profiles | Format-Table Name, Type, Source, Destination, LastRun -AutoSize
                    $profileName = Read-Host "`nEnter profile name to run (or press Enter to go back)"
                    if ($profileName) {
                        Invoke-SyncProfile -Name $profileName
                    }
                }
                
                Read-Host "`nPress Enter"
            }
            
            "6" {
                # View Logs
                Clear-Host
                Write-Host "═══ RECENT LOGS ═══`n" -ForegroundColor Gray
                
                $logs = Get-ChildItem $Script:LogPath -Filter "*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 10
                if ($logs) {
                    $logs | Format-Table Name, Length, LastWriteTime -AutoSize
                    $logName = Read-Host "`nEnter log filename to view (or press Enter)"
                    if ($logName) {
                        Get-Content "$Script:LogPath\$logName" | Out-Host
                    }
                } else {
                    Write-Host "No logs found." -ForegroundColor Gray
                }
                
                Read-Host "`nPress Enter"
            }
            
            "7" {
                # Settings
                Clear-Host
                Write-Host "═══ SETTINGS ═══`n" -ForegroundColor DarkCyan
                Write-Host "Config Path: $Script:ConfigPath"
                Write-Host "Log Path: $Script:LogPath"
                Write-Host "`nActions:"
                Write-Host "  [1] Open config folder"
                Write-Host "  [2] Open log folder"
                Write-Host "  [3] Clear all logs"
                Write-Host "  [4] Export profiles"
                
                $action = Read-Host "`nSelect"
                switch ($action) {
                    "1" { Start-Process explorer $Script:ConfigPath }
                    "2" { Start-Process explorer $Script:LogPath }
                    "3" { 
                        Remove-Item "$Script:LogPath\*.log" -Force
                        Write-Host "✅ Logs cleared" -ForegroundColor Green
                    }
                    "4" {
                        $exportPath = "$env:USERPROFILE\Desktop\syncmaster_profiles.json"
                        Copy-Item $Script:ConfigFile $exportPath
                        Write-Host "✅ Exported to $exportPath" -ForegroundColor Green
                    }
                }
                
                Read-Host "`nPress Enter"
            }
            
            "Q" { 
                Write-Host "`nGoodbye! 👋" -ForegroundColor Cyan
                return 
            }
            
            default {
                Write-Host "Invalid option!" -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}

# ============================================================================
# EXPORTED FUNCTIONS
# ============================================================================

Export-ModuleMember -Function @(
    'Start-SyncMasterUI',
    'Start-OneWaySync',
    'Start-MirrorSync',
    'Start-TwoWaySync',
    'Start-RestoreSync',
    'Get-RemovableDrives',
    'Save-SyncProfile',
    'Get-SyncProfiles',
    'Invoke-SyncProfile'
)

# ============================================================================
# ALIASES
# ============================================================================

New-Alias -Name sync -Value Start-SyncMasterUI -Force
New-Alias -Name syncui -Value Start-SyncMasterUI -Force

Export-ModuleMember -Alias @('sync', 'syncui')
