@{
    # Script module or binary module file associated with this manifest
    RootModule = 'SyncMaster.psm1'
    
    # Version number of this module
    ModuleVersion = '1.0.0'
    
    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')
    
    # ID used to uniquely identify this module
    GUID = 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d'
    
    # Author of this module
    Author = 'SyncMaster Contributors'
    
    # Company or vendor of this module
    CompanyName = 'Community'
    
    # Copyright statement for this module
    Copyright = '(c) 2024 SyncMaster Contributors. All rights reserved.'
    
    # Description of the functionality provided by this module
    Description = 'Advanced file synchronization tool for Windows with interactive UI, multiple sync modes, profile management, and comprehensive logging. Wraps Windows Robocopy with user-friendly interface.'
    
    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'
    
    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''
    
    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''
    
    # Minimum version of Microsoft .NET Framework required by this module
    # DotNetFrameworkVersion = ''
    
    # Minimum version of the common language runtime (CLR) required by this module
    # ClrVersion = ''
    
    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''
    
    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()
    
    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()
    
    # Script files (.ps1) that are run in the caller's environment prior to importing this module
    # ScriptsToProcess = @()
    
    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()
    
    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()
    
    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()
    
    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry
    FunctionsToExport = @(
        'Start-SyncMasterUI',
        'Start-OneWaySync',
        'Start-MirrorSync',
        'Start-TwoWaySync',
        'Start-RestoreSync',
        'Get-RemovableDrives',
        'Get-LocalFolders',
        'Save-SyncProfile',
        'Get-SyncProfiles',
        'Invoke-SyncProfile'
    )
    
    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry
    CmdletsToExport = @()
    
    # Variables to export from this module
    VariablesToExport = @()
    
    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry
    AliasesToExport = @('sync', 'syncui')
    
    # DSC resources to export from this module
    # DscResourcesToExport = @()
    
    # List of all modules packaged with this module
    # ModuleList = @()
    
    # List of all files packaged with this module
    FileList = @('SyncMaster.psm1', 'SyncMaster.psd1')
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries
            Tags = @(
                'Backup',
                'Sync',
                'Synchronization',
                'Robocopy',
                'FileTransfer',
                'USB',
                'Copy',
                'Mirror',
                'TwoWay',
                'Automation',
                'Windows'
            )
            
            # A URL to the license for this module
            LicenseUri = 'https://github.com/mini-page/SyncMaster/blob/main/LICENSE'
            
            # A URL to the main website for this project
            ProjectUri = 'https://github.com/mini-page/SyncMaster'
            
            # A URL to an icon representing this module
            # IconUri = ''
            
            # ReleaseNotes of this module
            ReleaseNotes = @'
# SyncMaster v1.0.0 Release Notes

## Features
- Interactive menu-driven interface
- Multiple sync modes: One-Way, Mirror, Two-Way, Restore
- Profile management for saving sync configurations
- Automatic removable drive detection
- Preview mode (dry-run) for safe testing
- Comprehensive logging system
- Multi-threaded file transfers
- Smart file and folder exclusions
- Customizable retry and wait settings
- Quick folder selection for common locations

## Requirements
- Windows 10/11 or Windows Server 2016+
- PowerShell 5.1 or higher
- Robocopy (included in Windows)

## Installation
Run INSTALL.ps1 or manually copy to PowerShell modules folder.

## Usage
Start-SyncMasterUI or use alias: sync

For detailed documentation, see README.md
'@
            
            # Prerelease string of this module
            # Prerelease = ''
            
            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = $false
            
            # External dependent modules of this module
            # ExternalModuleDependencies = @()
        }
    }
    
    # HelpInfo URI of this module
    # HelpInfoURI = ''
    
    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix
    # DefaultCommandPrefix = ''
}
