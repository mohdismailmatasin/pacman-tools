#!/bin/bash
# package-info.sh: Package information and search utility

source "$(dirname "$0")/logger.sh"

show_help() {
    echo "Package Information Utility"
    echo "Usage: $0 [OPTION] [PACKAGE_NAME]"
    echo
    echo "Options:"
    echo "  -s, --search TERM     Search for packages containing TERM"
    echo "  -i, --info PACKAGE    Show detailed information about PACKAGE"
    echo "  -f, --files PACKAGE   Show files installed by PACKAGE"
    echo "  -d, --deps PACKAGE    Show dependencies of PACKAGE"
    echo "  -r, --rdeps PACKAGE   Show reverse dependencies (what depends on PACKAGE)"
    echo "  -o, --owner FILE      Find which package owns FILE"
    echo "  -l, --list            List all installed packages"
    echo "  -e, --explicit        List explicitly installed packages"
    echo "  -u, --unused          Find potentially unused packages"
    echo "  -h, --help            Show this help message"
    echo
    echo "Examples:"
    echo "  $0 -s firefox         # Search for firefox packages"
    echo "  $0 -i vim             # Show info about vim package"
    echo "  $0 -f bash            # Show files installed by bash"
    echo "  $0 -o /usr/bin/vim    # Find which package owns /usr/bin/vim"
}

search_packages() {
    local term="$1"
    log_info "Searching for packages containing '$term'..."
    
    echo "Repository packages:"
    pacman -Ss "$term" | head -20
    
    if command -v yay >/dev/null 2>&1; then
        echo
        echo "AUR packages:"
        yay -Ss "$term" | head -10
    fi
}

show_package_info() {
    local package="$1"
    log_info "Showing information for package '$package'..."
    
    if pacman -Qi "$package" &>/dev/null; then
        echo "=== INSTALLED PACKAGE INFO ==="
        pacman -Qi "$package"
    else
        echo "Package '$package' is not installed. Searching repository..."
        pacman -Si "$package" 2>/dev/null || echo "Package '$package' not found in repositories."
    fi
}

show_package_files() {
    local package="$1"
    log_info "Showing files for package '$package'..."
    
    if pacman -Qi "$package" &>/dev/null; then
        echo "=== FILES INSTALLED BY $package ==="
        pacman -Ql "$package" | head -50
        local total=$(pacman -Ql "$package" | wc -l)
        echo "... ($total total files)"
    else
        echo "Package '$package' is not installed."
    fi
}

show_dependencies() {
    local package="$1"
    log_info "Showing dependencies for package '$package'..."
    
    if pacman -Qi "$package" &>/dev/null; then
        echo "=== DEPENDENCIES OF $package ==="
        pacman -Qi "$package" | grep -E "Depends On|Optional Deps"
    else
        echo "Package '$package' is not installed."
    fi
}

show_reverse_dependencies() {
    local package="$1"
    log_info "Finding packages that depend on '$package'..."
    
    echo "=== PACKAGES THAT DEPEND ON $package ==="
    pacman -Qi | grep -B5 -A5 "Depends On.*$package" | grep "^Name" | awk '{print $3}' | sort -u
}

find_package_owner() {
    local file="$1"
    log_info "Finding package owner of '$file'..."
    
    local owner=$(pacman -Qo "$file" 2>/dev/null)
    if [[ $? -eq 0 ]]; then
        echo "$owner"
    else
        echo "File '$file' is not owned by any package."
    fi
}

list_installed_packages() {
    log_info "Listing all installed packages..."
    
    local count=$(pacman -Q | wc -l)
    echo "=== INSTALLED PACKAGES ($count total) ==="
    pacman -Q | head -20
    echo "... (showing first 20 packages)"
}

list_explicit_packages() {
    log_info "Listing explicitly installed packages..."
    
    local count=$(pacman -Qe | wc -l)
    echo "=== EXPLICITLY INSTALLED PACKAGES ($count total) ==="
    pacman -Qe
}

find_unused_packages() {
    log_info "Finding potentially unused packages..."
    
    echo "=== ORPHANED PACKAGES ==="
    local orphans=$(pacman -Qtdq 2>/dev/null)
    if [[ -n "$orphans" ]]; then
        echo "$orphans"
    else
        echo "No orphaned packages found."
    fi
    
    echo
    echo "=== PACKAGES WITH NO REVERSE DEPENDENCIES ==="
    echo "(These might be safe to remove if you don't use them)"
    
    # Find packages that are not dependencies of other packages
    comm -23 <(pacman -Qe | awk '{print $1}' | sort) <(pacman -Qi | grep -E "^Depends On" | sed 's/Depends On[[:space:]]*:[[:space:]]*//' | tr ' ' '\n' | sort -u)
}

# Main logic
case "$1" in
    -s|--search)
        [[ -z "$2" ]] && { echo "Error: Search term required"; show_help; exit 1; }
        search_packages "$2"
        ;;
    -i|--info)
        [[ -z "$2" ]] && { echo "Error: Package name required"; show_help; exit 1; }
        show_package_info "$2"
        ;;
    -f|--files)
        [[ -z "$2" ]] && { echo "Error: Package name required"; show_help; exit 1; }
        show_package_files "$2"
        ;;
    -d|--deps)
        [[ -z "$2" ]] && { echo "Error: Package name required"; show_help; exit 1; }
        show_dependencies "$2"
        ;;
    -r|--rdeps)
        [[ -z "$2" ]] && { echo "Error: Package name required"; show_help; exit 1; }
        show_reverse_dependencies "$2"
        ;;
    -o|--owner)
        [[ -z "$2" ]] && { echo "Error: File path required"; show_help; exit 1; }
        find_package_owner "$2"
        ;;
    -l|--list)
        list_installed_packages
        ;;
    -e|--explicit)
        list_explicit_packages
        ;;
    -u|--unused)
        find_unused_packages
        ;;
    -h|--help|"")
        show_help
        ;;
    *)
        echo "Error: Unknown option '$1'"
        show_help
        exit 1
        ;;
esac
