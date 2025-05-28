#!/bin/bash
# arch-system-update.sh: Comprehensive system update for Arch Linux

set -euo pipefail

# Colors for output
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

log() {
  echo -e "${GREEN}[INFO]${RESET} $1"
}
warn() {
  echo -e "${YELLOW}[WARN]${RESET} $1"
}
error() {
  echo -e "${RED}[ERROR]${RESET} $1"
}

log "Starting comprehensive Arch Linux system update..."

# 1. Update system packages
log "Updating system packages (pacman)..."
sudo pacman -Syu --noconfirm || error "Pacman update failed!"

# 2. Update AUR packages (if yay or paru is installed)
if command -v yay >/dev/null 2>&1; then
  log "Updating AUR packages (yay)..."
  yay -Syu --noconfirm || warn "AUR update (yay) failed!"
elif command -v paru >/dev/null 2>&1; then
  log "Updating AUR packages (paru)..."
  paru -Syu --noconfirm || warn "AUR update (paru) failed!"
else
  warn "No AUR helper (yay/paru) found. Skipping AUR update."
fi

# 3. Check for .pacnew and .pacsave files
log "Checking for .pacnew and .pacsave files..."
find /etc -type f \( -name '*.pacnew' -o -name '*.pacsave' \) 2>/dev/null | tee /tmp/pacnew_pacsave_list.txt
if [[ -s /tmp/pacnew_pacsave_list.txt ]]; then
  warn "Found .pacnew/.pacsave files. Please review them:"
  cat /tmp/pacnew_pacsave_list.txt
else
  log "No .pacnew or .pacsave files found."
fi

# 4. Remove orphaned packages
log "Removing orphaned packages..."
orphans=$(pacman -Qtdq 2>/dev/null || true)
if [[ -n "$orphans" ]]; then
  echo "$orphans" | sudo pacman -Rns --noconfirm -
  log "Orphaned packages removed."
else
  log "No orphaned packages to remove."
fi

# 5. Clean package cache
log "Cleaning package cache (keeping last 3 versions)..."
sudo paccache -r -k3 || warn "paccache not found or failed. Skipping cache clean."

# 6. Optionally update system firmware (fwupd)
if command -v fwupdmgr >/dev/null 2>&1; then
  log "Checking for firmware updates..."
  sudo fwupdmgr refresh && sudo fwupdmgr get-updates && sudo fwupdmgr update || warn "Firmware update failed or not available."
else
  warn "fwupdmgr not found. Skipping firmware update."
fi

log "System update complete!"
echo -e "\n${GREEN}Summary:${RESET}"
echo "- System packages updated"
echo "- AUR packages updated (if helper found)"
echo "- Checked for .pacnew/.pacsave files"
echo "- Orphaned packages removed"
echo "- Package cache cleaned"
echo "- Firmware updated (if supported)"
