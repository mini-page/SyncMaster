#Requires -Version 5.1

<#
.SYNOPSIS
    SyncMaster Installation Script
.DESCRIPTION
    Automatically installs SyncMaster PowerShell module to your system
.PARAMETER Scope
    Install scope: CurrentUser or AllUsers (AllUsers requires Admin)
.PARAMETER Force
    Force reinstall even if already installed
.EXAMPLE
    .\INSTALL.ps1
.EXAMPLE
    .\INSTALL.ps1 -Scope AllUsers
.EXAMPLE
    .\INSTALL.ps1 -Force
#>

param(
    [ValidateSet('CurrentUser', 'AllUsers')]
    [string]$Scope = 'CurrentUser',
    [switch]$Force
)

# ============================================================================
# CONFIGURATION
# ============================================================================

$ModuleName = 'SyncMaster'
$RequiredFiles = @('SyncMaster.psm1', 'SyncMaster.psd1')

# ============================================================================
# FUNCTIONS
# ============================================================================

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = 'White'
    )
    Write-Host $Message -ForegroundColor $Color
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-InstallPath {
    param([string]$Scope)
    
    if ($Scope -eq 'AllUsers') {
        return "$env:ProgramFiles\WindowsPowerShell\Modules\$ModuleName"
    } else {
        return "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\$ModuleName"
    }
}

function Test-ModuleInstalled {
    param([string]$Path)
    
    if (Test-Path $Path) {
        $installedVersion = $null
        $manifestPath = Join-Path $Path "$ModuleName.psd1"
        
        if (Test-Path $manifestPath) {
            try {
                $manifest = Import-PowerShellDataFile $manifestPath
                $installedVersion = $manifest.ModuleVersion
            } catch {
                $installedVersion = "Unknown"
            }
        }
        
        return @{
            Installed = $true
            Version = $installedVersion
            Path = $Path
        }
    }
    
    return @{Installed = $false}
}

# ============================================================================
# MAIN INSTALLATION
# ============================================================================

Clear-Host

Write-ColorOutput "╔════════════════════════════════════════════════════════╗" Cyan
Write-ColorOutput "║         SYNCMASTER INSTALLATION SCRIPT                ║" Cyan
Write-ColorOutput "╚════════════════════════════════════════════════════════╝" Cyan
Write-Host ""

# Check if running in correct directory
$currentPath = Get-Location
$moduleFile = Join-Path $currentPath "SyncMaster.psm1"

if (-not (Test-Path $moduleFile)) {
    Write-ColorOutput "❌ ERROR: SyncMaster.psm1 not found in current directory!" Red
    Write-ColorOutput "   Please run this script from the SyncMaster directory." Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Check for required files
Write-ColorOutput "🔍 Checking required files..." White
$missingFiles = @()
foreach ($file in $RequiredFiles) {
    if (-not (Test-Path (Join-Path $currentPath $file))) {
        $missingFiles += $file
    } else {
        Write-ColorOutput "   ✓ Found: $file" Green
    }
}

if ($missingFiles.Count -gt 0) {
    Write-ColorOutput "`n❌ Missing required files:" Red
    $missingFiles | ForEach-Object { Write-ColorOutput "   - $_" Red }
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Check administrator rights if AllUsers scope
if ($Scope -eq 'AllUsers' -and -not (Test-Administrator)) {
    Write-ColorOutput "`n⚠️  WARNING: Installing for AllUsers requires Administrator rights!" Yellow
    Write-ColorOutput "   Please run PowerShell as Administrator or use -Scope CurrentUser" Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Determine installation path
$installPath = Get-InstallPath -Scope $Scope
Write-ColorOutput "`n📁 Installation Path:" Cyan
Write-ColorOutput "   $installPath" White

# Check if already installed
$existingInstall = Test-ModuleInstalled -Path $installPath

if ($existingInstall.Installed) {
    Write-ColorOutput "`n⚠️  Module already installed!" Yellow
    Write-ColorOutput "   Version: $($existingInstall.Version)" Gray
    Write-ColorOutput "   Location: $($existingInstall.Path)" Gray
    
    if (-not $Force) {
        $response = Read-Host "`nReinstall/Update? (y/n)"
        if ($response -ne 'y') {
            Write-ColorOutput "`nInstallation cancelled." Yellow
            Read-Host "Press Enter to exit"
            exit 0
        }
    } else {
        Write-ColorOutput "   Force flag detected - proceeding with reinstall" Yellow
    }
    
    # Remove old installation
    Write-ColorOutput "`n🗑️  Removing old installation..." Yellow
    try {
        Remove-Item -Path $installPath -Recurse -Force -ErrorAction Stop
        Write-ColorOutput "   ✓ Old version removed" Green
    } catch {
        Write-ColorOutput "   ❌ Failed to remove old version: $_" Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Create installation directory
Write-ColorOutput "`n📦 Creating installation directory..." White
try {
    New-Item -ItemType Directory -Path $installPath -Force | Out-Null
    Write-ColorOutput "   ✓ Directory created" Green
} catch {
    Write-ColorOutput "   ❌ Failed to create directory: $_" Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Copy module files
Write-ColorOutput "`n📋 Copying module files..." White
try {
    foreach ($file in $RequiredFiles) {
        $sourcePath = Join-Path $currentPath $file
        $destPath = Join-Path $installPath $file
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        Write-ColorOutput "   ✓ Copied: $file" Green
    }
} catch {
    Write-ColorOutput "   ❌ Failed to copy files: $_" Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Import the module
Write-ColorOutput "`n🔄 Importing module..." White
try {
    Import-Module $installPath -Force
    Write-ColorOutput "   ✓ Module imported successfully" Green
} catch {
    Write-ColorOutput "   ⚠️  Warning: Module installed but import failed: $_" Yellow
    Write-ColorOutput "   You may need to restart PowerShell" Yellow
}

# Verify installation
Write-ColorOutput "`n✅ Verifying installation..." White
$module = Get-Module -Name $ModuleName -ListAvailable | Where-Object { $_.Path -like "*$installPath*" }

if ($module) {
    Write-ColorOutput "   ✓ Module version: $($module.Version)" Green
    Write-ColorOutput "   ✓ Location: $($module.ModuleBase)" Green
} else {
    Write-ColorOutput "   ⚠️  Module installed but not detected in module path" Yellow
}

# Check available commands
Write-ColorOutput "`n📚 Available Commands:" Cyan
try {
    $commands = Get-Command -Module $ModuleName | Select-Object -ExpandProperty Name
    foreach ($cmd in $commands) {
        Write-ColorOutput "   • $cmd" White
    }
} catch {
    Write-ColorOutput "   Could not list commands (restart PowerShell may be needed)" Gray
}

# Success message
Write-Host ""
Write-ColorOutput "╔════════════════════════════════════════════════════════╗" Green
Write-ColorOutput "║          ✅ INSTALLATION COMPLETED SUCCESSFULLY!       ║" Green
Write-ColorOutput "╚════════════════════════════════════════════════════════╝" Green
Write-Host ""

Write-ColorOutput "🚀 Quick Start:" Cyan
Write-ColorOutput "   1. Open a new PowerShell window (or restart current)" White
Write-ColorOutput "   2. Run: Start-SyncMasterUI" White
Write-ColorOutput "   3. Or use the alias: sync" White
Write-Host ""

Write-ColorOutput "📖 For help, run:" Cyan
Write-ColorOutput "   Get-Help Start-SyncMasterUI -Full" White
Write-Host ""

# Offer to add to profile
$addToProfile = Read-Host "Add auto-import to PowerShell profile? (y/n)"
if ($addToProfile -eq 'y') {
    try {
        $profilePath = $PROFILE
        $importLine = "`n# SyncMaster Module`nImport-Module SyncMaster`n"
        
        # Create profile if doesn't exist
        if (-not (Test-Path $profilePath)) {
            New-Item -ItemType File -Path $profilePath -Force | Out-Null
        }
        
        # Check if already in profile
        $profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
        if ($profileContent -notlike "*Import-Module SyncMaster*") {
            Add-Content -Path $profilePath -Value $importLine
            Write-ColorOutput "`n✅ Added to profile: $profilePath" Green
            Write-ColorOutput "   Module will auto-load in new PowerShell sessions" Green
        } else {
            Write-ColorOutput "`n✓ Already in profile" Yellow
        }
    } catch {
        Write-ColorOutput "`n⚠️  Could not update profile: $_" Yellow
    }
}

# Offer to run now
Write-Host ""
$runNow = Read-Host "Launch SyncMaster now? (y/n)"
if ($runNow -eq 'y') {
    Write-Host ""
    Start-SyncMasterUI
}

Write-ColorOutput "`nThank you for installing SyncMaster! 🎉" Cyan
Write-Host ""
