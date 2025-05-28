# Arch Linux Maintenance Scripts

A collection of shell scripts for maintaining and optimizing Arch Linux systems.

## Overview

This repository contains scripts to automate common maintenance tasks for Arch Linux, helping you keep your system clean, up-to-date, and running smoothly.

## Scripts

- **main.sh**: Interactive menu to access all maintenance tools
- **arch-system-update.sh**: Comprehensive system updater that:
  - Updates system packages via pacman
  - Updates AUR packages (if yay/paru is installed)
  - Checks for .pacnew/.pacsave files
  - Removes orphaned packages
  - Cleans package cache
  - Updates firmware (if fwupd is available)
- **pacman-cleaner.sh**: System cleaning utility that:
  - Clears pacman cache (keeping recent versions)
  - Removes orphaned packages
  - Cleans package cache completely
  - Refreshes package databases
- **pacman-fixer.sh**: Package integrity checker that:
  - Scans for package file issues using pacman -Qkk
  - Identifies problematic packages
  - Automatically reinstalls affected packages

## Usage

1. Clone the repository:

   ```bash
   git clone https://github.com/mohdismailmatasin/pacman-tools.git
   cd pacman-tools
   ```

2. Make scripts executable:

   ```bash
   chmod +x *.sh
   ```

3. Run the main menu:

   ```bash
   ./main.sh
   ```

## Requirements

- Arch Linux or Arch-based distribution
- Bash/Zsh shell
- Root privileges (sudo)

## License

[MIT](LICENSE)