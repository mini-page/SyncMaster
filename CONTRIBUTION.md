# Contributing to SyncMaster

First off, thank you for considering contributing to SyncMaster! It's people like you that make SyncMaster such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by a simple principle: **Be respectful and constructive.**

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

**Bug Report Template:**
```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Run command '...'
2. Select option '....'
3. See error

**Expected behavior**
What you expected to happen.

**Screenshots/Logs**
If applicable, add screenshots or log files.

**Environment:**
 - OS: [e.g. Windows 11]
 - PowerShell Version: [e.g. 5.1]
 - SyncMaster Version: [e.g. 1.0.0]

**Additional context**
Any other context about the problem.
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Use a clear and descriptive title**
- **Provide a detailed description** of the suggested enhancement
- **Explain why this enhancement would be useful** to most users
- **List any alternatives** you've considered

### Pull Requests

1. **Fork the repo** and create your branch from `main`
2. **Make your changes** and test thoroughly
3. **Update documentation** if needed
4. **Follow the coding style** used throughout the project
5. **Write a clear commit message** describing your changes
6. **Submit the pull request**

## Development Setup

### Prerequisites
- Windows 10/11
- PowerShell 5.1 or higher
- Git
- A code editor (VS Code recommended)

### Setting Up Development Environment

```powershell
# Clone the repository
git clone https://github.com/yourusername/SyncMaster.git
cd SyncMaster

# Import module for testing
Import-Module .\SyncMaster.psm1 -Force

# Run tests (if available)
# Invoke-Pester
```

### Testing Your Changes

Before submitting a pull request:

1. **Test all sync modes** (One-Way, Mirror, Two-Way, Restore)
2. **Test with different drive types** (USB, network, local)
3. **Test preview mode** (dry-run functionality)
4. **Test profile management** (save, load, delete)
5. **Verify logging works** correctly
6. **Check error handling** for edge cases

### Manual Testing Checklist

- [ ] Interactive UI launches without errors
- [ ] Drive detection works correctly
- [ ] Folder selection (quick and custom) works
- [ ] Preview mode (WhatIf) displays correctly
- [ ] Actual sync operations complete successfully
- [ ] Logs are created with proper timestamps
- [ ] Profile save/load works
- [ ] Exit codes are handled correctly
- [ ] Confirmation prompts work for destructive operations
- [ ] Error messages are clear and helpful

## Coding Style

### PowerShell Best Practices

1. **Function Names**: Use approved PowerShell verbs (Get, Set, Start, etc.)
   ```powershell
   # Good
   function Get-SyncStatus { }
   
   # Bad
   function FetchSyncStatus { }
   ```

2. **Parameter Naming**: Use PascalCase
   ```powershell
   param(
       [string]$SourcePath,
       [switch]$WhatIf
   )
   ```

3. **Comments**: Add comments for complex logic
   ```powershell
   # Calculate retry interval based on file size
   $retryInterval = [Math]::Min(30, $fileSize / 1MB)
   ```

4. **Error Handling**: Use try-catch appropriately
   ```powershell
   try {
       # Operation
   } catch {
       Write-Error "Failed: $_"
       return $false
   }
   ```

5. **Help Documentation**: Include comment-based help
   ```powershell
   <#
   .SYNOPSIS
       Brief description
   .DESCRIPTION
       Detailed description
   .PARAMETER Name
       Parameter description
   .EXAMPLE
       Example usage
   #>
   ```

### Formatting

- Use **4 spaces** for indentation (no tabs)
- Keep lines under **120 characters** when possible
- Add blank lines between logical sections
- Use consistent brace style:
  ```powershell
  if ($condition) {
      # code
  }
  ```

### Variable Naming

- **Script-level variables**: `$Script:VariableName`
- **Local variables**: `$camelCase` or `$PascalCase`
- **Boolean flags**: Use `$is`, `$has`, `$should` prefix
  ```powershell
  $isValid = $true
  $hasErrors = $false
  ```

## Documentation

- Update README.md if adding new features
- Add inline comments for complex logic
- Update help text in functions
- Add examples to demonstrate new features

## Commit Messages

### Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, etc.)
- **refactor**: Code refactoring
- **test**: Adding tests
- **chore**: Maintenance tasks

### Examples
```
feat(sync): Add bandwidth throttling option

Implemented IPG parameter support for network sync operations.
Allows users to control network usage during large transfers.

Closes #42
```

```
fix(ui): Correct drive detection on Windows 11

Fixed issue where some USB drives weren't detected due to
partition type checking. Now uses more robust detection method.

Fixes #38
```

## Project Structure

```
SyncMaster/
├── SyncMaster.psm1      # Main module file
├── SyncMaster.psd1      # Module manifest
├── INSTALL.ps1          # Installation script
├── README.md            # Documentation
├── LICENSE              # MIT License
├── CONTRIBUTING.md      # This file
├── CHANGELOG.md         # Version history
└── .github/
    ├── ISSUE_TEMPLATE/
    │   ├── bug_report.md
    │   └── feature_request.md
    └── workflows/
        └── tests.yml
```

## Feature Requests

We love feature requests! Here's how to submit one:

1. **Check existing issues** to avoid duplicates
2. **Create a new issue** with the label "enhancement"
3. **Describe the feature** in detail
4. **Explain the use case** - why would this be valuable?
5. **Provide examples** if possible

### Popular Feature Ideas

Some areas where contributions would be especially welcome:

- [ ] Cloud storage integration (OneDrive, Dropbox, etc.)
- [ ] Compression support for archived files
- [ ] Email notifications on completion
- [ ] Web-based monitoring interface
- [ ] Incremental backup with versioning
- [ ] Bandwidth throttling UI
- [ ] Custom file filters (by size, date, type)
- [ ] Conflict resolution strategies for two-way sync
- [ ] Unit tests using Pester
- [ ] Integration with Task Scheduler GUI

## Questions?

Don't hesitate to ask questions! You can:

- Open an issue with the "question" label
- Start a discussion in GitHub Discussions
- Comment on existing issues or pull requests

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- GitHub contributors page

Thank you for contributing to SyncMaster! 🎉
