# Arch Linux Maintenance Scripts

A comprehensive collection of shell scripts for maintaining and optimizing Arch Linux systems with enhanced logging, configuration, and system health monitoring.

## 🚀 Features

- **Interactive Menu System**: Easy-to-use menu for accessing all tools
- **Comprehensive System Updates**: Automated pacman, AUR, and firmware updates
- **System Health Monitoring**: Real-time system health checks and reporting
- **Package Management**: Advanced package information and dependency tracking
- **Intelligent Cleaning**: Smart cache management and orphan package removal
- **Package Integrity Checking**: Automated detection and repair of package issues
- **Configurable Settings**: Customizable behavior through configuration files
- **Unified Logging**: Centralized logging with different log levels
- **Safety Features**: Confirmation prompts and backup options

## 📋 Scripts Overview

### Core Tools

- **`main.sh`**: Interactive menu to access all maintenance tools
- **`arch-system-update.sh`**: Comprehensive system updater
- **`pacman-cleaner.sh`**: System cleaning utility with progress tracking
- **`pacman-fixer.sh`**: Package integrity checker and repair tool

### New Enhanced Tools

- **`system-health-check.sh`**: Comprehensive system health monitoring
- **`package-info.sh`**: Advanced package information and search utility
- **`logger.sh`**: Unified logging system for all scripts
- **`config.conf`**: Configuration file for customizing behavior
- **`install.sh`**: Automated installation and setup script

## 🔧 Installation

### Quick Installation

```bash
git clone https://github.com/mohdismailmatasin/pacman-tools.git
cd pacman-tools
chmod +x install.sh
./install.sh
```

### Manual Installation

```bash
git clone https://github.com/mohdismailmatasin/pacman-tools.git
cd pacman-tools
chmod +x *.sh
./main.sh
```

## 🎯 Usage

### Interactive Menu

```bash
pacman-tools  # If installed globally
# or
./main.sh
```

```bash
=======================================
    Arch Linux Maintenance Menu
=======================================
1) System Update
2) Pacman Cleaner
3) Pacman Fixer
4) System Health Check
5) Package Information
6) View Configuration
7) Exit
=======================================
Select an option [1-7]: 4
[INFO] Starting Arch Linux system health check...
[INFO] Checking disk space...
[INFO] Checking package database integrity...
[INFO] Checking for available updates...
[INFO] Checking for orphaned packages...
[INFO] Checking for failed systemd services...
[INFO] Checking kernel version...
[INFO] Checking memory usage...
[INFO] Checking for .pacnew/.pacsave files...

===============================
    SYSTEM HEALTH REPORT
===============================

✓ OK: System is up to date
✓ OK: Root partition 19% full
✓ OK: No orphaned packages
✓ OK: Boot partition 17% full
✓ OK: No .pacnew/.pacsave files
✓ OK: Memory usage 25%
✓ OK: Package database is healthy
✓ OK: All systemd services running
✓ OK: Kernel 6.15.6-arch1-1 (pacman: 6.15.6.arch1-1)

===============================
Summary: 9 OK, 0 Warnings, 0 Critical
===============================
System is healthy!
Press Enter to return to menu...
```

### Individual Tools

```bash
# System update
arch-system-update

# System cleaning
pacman-cleaner

# Package repair
pacman-fixer

# Health check
system-health-check

# Package information
package-info -h  # Show help
package-info -s firefox  # Search packages
package-info -i vim  # Package info
package-info -u  # Find unused packages
```

## ⚙️ Configuration

Edit `config.conf` to customize behavior:

```bash
# Cache cleaning settings
CACHE_KEEP_VERSIONS=3
CACHE_CLEAN_AGGRESSIVE=false

# Update settings
AUTO_CONFIRM=false
UPDATE_AUR=true
UPDATE_FIRMWARE=true

# Logging settings
LOG_LEVEL=INFO
LOG_FILE="pacman-tools.log"
```

## 📊 System Health Check

The health check monitors:

- 💾 Disk space usage
- 📦 Package database integrity
- 🔄 Available system updates
- 🗑️ Orphaned packages
- ⚙️ Failed systemd services
- 🔧 Kernel version status
- 🧠 Memory usage
- 📄 Configuration file conflicts

## 🔍 Package Information Tool

Advanced package management features:

- 🔍 Search packages in repos and AUR
- 📝 Detailed package information
- 📁 List files installed by packages
- 🔗 Show package dependencies
- 🔄 Find reverse dependencies
- 👤 Find package owner of files
- 📊 List installed/explicit packages
- 🧹 Find unused packages

## 📝 Enhanced Features

### Intelligent Updates

- Pacman system updates
- AUR package updates (yay/paru)
- Firmware updates (fwupd)
- Configuration file conflict detection
- Orphan package cleanup
- Smart cache management

### Advanced Cleaning

- Progress tracking with spinners
- Configurable cache retention
- Comprehensive orphan removal
- Database refresh
- Detailed operation summaries

### Package Integrity

- Deep package file verification
- Automatic problematic package detection
- Batch package reinstallation
- Detailed issue reporting
- Progress tracking

## 🔒 Safety Features

- Configuration backups
- Confirmation prompts
- Detailed logging
- Error handling
- Rollback capabilities

## 📋 Requirements

- Arch Linux or Arch-based distribution
- Bash/Zsh shell
- Root privileges (sudo)

## License

[MIT](LICENSE)