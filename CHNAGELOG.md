# Changelog

All notable changes to SyncMaster will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned Features
- Cloud storage support (OneDrive, Dropbox, Google Drive)
- GUI version using Windows Forms
- Email notifications on sync completion
- Compression options for archival
- Bandwidth throttling controls in UI
- Unit tests using Pester framework
- PowerShell Gallery publishing

## [1.0.0] - 2024-11-04

### Added
- Initial release of SyncMaster
- Interactive menu-driven UI with color-coded options
- Multiple sync operation modes:
  - One-Way Sync (PC → USB)
  - Mirror Sync (exact copy with deletion)
  - Two-Way Sync (bidirectional merge)
  - Restore Mode (USB → PC)
- Automatic removable drive detection
- Quick folder selection for common user directories
- Profile management system:
  - Save sync configurations
  - Load and run saved profiles
  - View profile history
- Comprehensive logging system:
  - Timestamped log files
  - Log viewer in UI
  - Export capabilities
- Preview mode (dry-run) with WhatIf parameter
- Multi-threaded file transfers (configurable thread count)
- Smart exclusions:
  - System folders ($RECYCLE.BIN, System Volume Information)
  - Temporary files (*.tmp, *.log)
  - Hidden system files (Thumbs.db, desktop.ini)
- Customizable sync options:
  - Retry count and wait time
  - Thread count configuration
  - Copy all attributes (security, ownership)
  - Custom file and folder exclusions
- Robocopy exit code handling and interpretation
- Safety features:
  - Confirmation prompts for destructive operations
  - Warning messages for mirror/delete operations
  - Automatic logging of all operations
- Configuration storage in user profile
- PowerShell aliases: `sync` and `syncui`
- Automated installation script (INSTALL.ps1)
- Module manifest for PowerShell Gallery compatibility
- Comprehensive documentation:
  - README with examples and use cases
  - Contributing guidelines
  - MIT License
  - Detailed inline code comments

### Technical Details
- PowerShell 5.1+ compatibility
- JSON-based configuration storage
- Wrapper around Windows Robocopy utility
- Script-level variables for configuration paths
- Export of core functions and aliases
- Organized code structure with clear sections:
  - Module variables
  - Initialization functions
  - Detection functions
  - Interactive menu functions
  - Sync operations
  - Profile management
  - Main workflow

### Known Limitations
- Windows-only (requires Robocopy)
- No native cloud storage support
- No built-in compression
- Single-instance only (no parallel syncs)
- Manual Task Scheduler setup required for automation

## Version History

### Version Numbering
- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality in backward-compatible manner
- **PATCH**: Backward-compatible bug fixes

---

## [Unreleased] - Future Versions

### [1.1.0] - Planned
#### Proposed Features
- [ ] Bandwidth throttling UI controls
- [ ] Advanced file filtering (by size, date, extension)
- [ ] Email notification support
- [ ] Scheduled task creation wizard
- [ ] Real-time sync monitoring
- [ ] Conflict resolution for two-way sync

### [1.2.0] - Planned
#### Proposed Features
- [ ] Cloud storage integration (OneDrive first)
- [ ] Compression support (ZIP, 7Z)
- [ ] Incremental backup with versioning
- [ ] File comparison tool
- [ ] Sync statistics dashboard

### [2.0.0] - Planned (Breaking Changes)
#### Proposed Features
- [ ] GUI application using Windows Forms
- [ ] Database backend for better profile management
- [ ] Multi-instance support
- [ ] Plugin architecture for extensibility
- [ ] Web-based monitoring interface
- [ ] RESTful API for automation

---

## Support

For issues, feature requests, or questions:
- **GitHub Issues**: [https://github.com/yourusername/SyncMaster/issues](https://github.com/yourusername/SyncMaster/issues)
- **Discussions**: [https://github.com/yourusername/SyncMaster/discussions](https://github.com/yourusername/SyncMaster/discussions)

## Links

- [GitHub Repository](https://github.com/yourusername/SyncMaster)
- [Installation Guide](README.md#installation)
- [Usage Documentation](README.md#usage-guide)
- [Contributing Guidelines](CONTRIBUTING.md)
