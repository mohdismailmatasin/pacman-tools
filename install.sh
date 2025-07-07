#!/bin/bash
# install.sh: Installation script for pacman-tools

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Arch Linux
check_arch_linux() {
    if [[ ! -f /etc/arch-release ]]; then
        print_error "This tool is designed for Arch Linux systems."
        print_error "Current system: $(uname -s)"
        exit 1
    fi
    print_status "Arch Linux detected."
}

# Check dependencies
check_dependencies() {
    print_status "Checking dependencies..."
    
    local missing_deps=()
    
    # Check for required commands
    for cmd in pacman sudo; do
        if ! command -v "$cmd" &>/dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        exit 1
    fi
    
    print_status "All dependencies satisfied."
}

# Install optional dependencies
install_optional_deps() {
    print_status "Checking optional dependencies..."
    
    # Check for AUR helpers
    if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
        print_warning "No AUR helper found (yay/paru). AUR package updates will be skipped."
        echo "Would you like to install yay? (y/N)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            print_status "Installing yay..."
            sudo pacman -S --needed git base-devel
            cd /tmp
            git clone https://aur.archlinux.org/yay.git
            cd yay
            makepkg -si --noconfirm
            cd - > /dev/null
            rm -rf /tmp/yay
            print_status "yay installed successfully."
        fi
    fi
    
    # Check for paccache
    if ! command -v paccache &>/dev/null; then
        print_warning "paccache not found. Installing pacman-contrib..."
        sudo pacman -S --needed pacman-contrib
    fi
    
    # Check for fwupdmgr
    if ! command -v fwupdmgr &>/dev/null; then
        print_warning "fwupdmgr not found. Firmware updates will be skipped."
        echo "Would you like to install fwupd? (y/N)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            sudo pacman -S --needed fwupd
        fi
    fi
}

# Set up scripts
setup_scripts() {
    print_status "Setting up pacman-tools..."
    
    # Make all scripts executable
    chmod +x *.sh
    
    # Create symlinks in /usr/local/bin for global access
    print_status "Creating global symlinks..."
    
    local script_dir="$(pwd)"
    local bin_dir="/usr/local/bin"
    
    # Create symlinks for main scripts
    sudo ln -sf "$script_dir/main.sh" "$bin_dir/pacman-tools"
    sudo ln -sf "$script_dir/arch-system-update.sh" "$bin_dir/arch-system-update"
    sudo ln -sf "$script_dir/pacman-cleaner.sh" "$bin_dir/pacman-cleaner"
    sudo ln -sf "$script_dir/pacman-fixer.sh" "$bin_dir/pacman-fixer"
    sudo ln -sf "$script_dir/system-health-check.sh" "$bin_dir/system-health-check"
    sudo ln -sf "$script_dir/package-info.sh" "$bin_dir/package-info"
    
    print_status "Symlinks created. You can now run 'pacman-tools' from anywhere."
}

# Create desktop entry
create_desktop_entry() {
    print_status "Creating desktop entry..."
    
    local desktop_file="$HOME/.local/share/applications/pacman-tools.desktop"
    local script_dir="$(pwd)"
    
    mkdir -p "$(dirname "$desktop_file")"
    
    cat > "$desktop_file" << EOF
[Desktop Entry]
Name=Pacman Tools
Comment=Arch Linux Package Management Tools
Exec=gnome-terminal --title="Pacman Tools" -- $script_dir/main.sh
Icon=system-software-update
Terminal=false
Type=Application
Categories=System;Settings;
EOF
    
    print_status "Desktop entry created."
}

# Main installation
main() {
    echo "=================================="
    echo "    Pacman Tools Installation"
    echo "=================================="
    echo
    
    check_arch_linux
    check_dependencies
    install_optional_deps
    setup_scripts
    
    echo "Would you like to create a desktop entry? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        create_desktop_entry
    fi
    
    echo
    echo "=================================="
    print_status "Installation complete!"
    echo "=================================="
    echo
    echo "Usage:"
    echo "  pacman-tools                 # Run interactive menu"
    echo "  arch-system-update           # Update system"
    echo "  pacman-cleaner               # Clean system"
    echo "  pacman-fixer                 # Fix package issues"
    echo "  system-health-check          # Check system health"
    echo "  package-info -h              # Package information tool"
    echo
    echo "Configuration file: $(pwd)/config.conf"
    echo "Logs will be saved to: $(pwd)/pacman-tools.log"
}

# Run installation
main "$@"
