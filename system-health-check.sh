#!/bin/bash
# system-health-check.sh: Comprehensive Arch Linux system health checker

source "$(dirname "$0")/logger.sh"

log_info "Starting Arch Linux system health check..."

# Health check results
declare -A HEALTH_RESULTS

# Check 1: Disk space
check_disk_space() {
    log_info "Checking disk space..."
    
    local root_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    local boot_usage=$(df /boot 2>/dev/null | awk 'NR==2 {print $5}' | sed 's/%//' || echo "0")
    
    if [[ $root_usage -gt 90 ]]; then
        HEALTH_RESULTS["disk_root"]="CRITICAL: Root partition ${root_usage}% full"
    elif [[ $root_usage -gt 80 ]]; then
        HEALTH_RESULTS["disk_root"]="WARNING: Root partition ${root_usage}% full"
    else
        HEALTH_RESULTS["disk_root"]="OK: Root partition ${root_usage}% full"
    fi
    
    if [[ $boot_usage -gt 80 ]]; then
        HEALTH_RESULTS["disk_boot"]="WARNING: Boot partition ${boot_usage}% full"
    else
        HEALTH_RESULTS["disk_boot"]="OK: Boot partition ${boot_usage}% full"
    fi
}

# Check 2: Package system integrity
check_package_integrity() {
    log_info "Checking package database integrity..."
    
    if sudo pacman -Dk &>/dev/null; then
        HEALTH_RESULTS["pkg_db"]="OK: Package database is healthy"
    else
        HEALTH_RESULTS["pkg_db"]="ERROR: Package database has issues"
    fi
}

# Check 3: System updates
check_updates() {
    log_info "Checking for available updates..."
    
    local updates=$(pacman -Qu 2>/dev/null | wc -l)
    if [[ $updates -gt 50 ]]; then
        HEALTH_RESULTS["updates"]="WARNING: ${updates} updates available"
    elif [[ $updates -gt 0 ]]; then
        HEALTH_RESULTS["updates"]="INFO: ${updates} updates available"
    else
        HEALTH_RESULTS["updates"]="OK: System is up to date"
    fi
}

# Check 4: Orphaned packages
check_orphans() {
    log_info "Checking for orphaned packages..."
    
    local orphans=$(pacman -Qtdq 2>/dev/null | wc -l)
    if [[ $orphans -gt 10 ]]; then
        HEALTH_RESULTS["orphans"]="WARNING: ${orphans} orphaned packages"
    elif [[ $orphans -gt 0 ]]; then
        HEALTH_RESULTS["orphans"]="INFO: ${orphans} orphaned packages"
    else
        HEALTH_RESULTS["orphans"]="OK: No orphaned packages"
    fi
}

# Check 5: Failed systemd services
check_systemd_services() {
    log_info "Checking for failed systemd services..."
    
    local failed=$(systemctl --failed --no-legend | wc -l)
    if [[ $failed -gt 0 ]]; then
        HEALTH_RESULTS["systemd"]="WARNING: ${failed} failed systemd services"
    else
        HEALTH_RESULTS["systemd"]="OK: All systemd services running"
    fi
}

# Check 6: Kernel version
check_kernel() {
    log_info "Checking kernel version..."
    
    local running_kernel=$(uname -r)
    local installed_kernel=$(pacman -Q linux 2>/dev/null | awk '{print $2}' || echo "not found")
    
    if [[ "$installed_kernel" == "not found" ]]; then
        HEALTH_RESULTS["kernel"]="INFO: Custom kernel in use: $running_kernel"
    else
        HEALTH_RESULTS["kernel"]="OK: Kernel $running_kernel (pacman: $installed_kernel)"
    fi
}

# Check 7: Memory usage
check_memory() {
    log_info "Checking memory usage..."
    
    local mem_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
    if [[ $mem_usage -gt 90 ]]; then
        HEALTH_RESULTS["memory"]="CRITICAL: Memory usage ${mem_usage}%"
    elif [[ $mem_usage -gt 80 ]]; then
        HEALTH_RESULTS["memory"]="WARNING: Memory usage ${mem_usage}%"
    else
        HEALTH_RESULTS["memory"]="OK: Memory usage ${mem_usage}%"
    fi
}

# Check 8: .pacnew/.pacsave files
check_pacnew_files() {
    log_info "Checking for .pacnew/.pacsave files..."
    
    local pacnew_count=$(find /etc -name "*.pacnew" -o -name "*.pacsave" 2>/dev/null | wc -l)
    if [[ $pacnew_count -gt 0 ]]; then
        HEALTH_RESULTS["pacnew"]="WARNING: ${pacnew_count} .pacnew/.pacsave files need attention"
    else
        HEALTH_RESULTS["pacnew"]="OK: No .pacnew/.pacsave files"
    fi
}

# Run all checks
run_health_checks() {
    check_disk_space
    check_package_integrity
    check_updates
    check_orphans
    check_systemd_services
    check_kernel
    check_memory
    check_pacnew_files
}

# Display results
display_results() {
    echo
    echo "==============================="
    echo "    SYSTEM HEALTH REPORT"
    echo "==============================="
    echo
    
    local critical=0
    local warnings=0
    local ok=0
    
    for check in "${!HEALTH_RESULTS[@]}"; do
        local result="${HEALTH_RESULTS[$check]}"
        if [[ $result == CRITICAL* ]]; then
            echo -e "\033[1;31m✗ $result\033[0m"
            ((critical++))
        elif [[ $result == WARNING* ]]; then
            echo -e "\033[1;33m⚠ $result\033[0m"
            ((warnings++))
        elif [[ $result == ERROR* ]]; then
            echo -e "\033[1;31m✗ $result\033[0m"
            ((critical++))
        else
            echo -e "\033[1;32m✓ $result\033[0m"
            ((ok++))
        fi
    done
    
    echo
    echo "==============================="
    echo "Summary: $ok OK, $warnings Warnings, $critical Critical"
    echo "==============================="
    
    if [[ $critical -gt 0 ]]; then
        echo -e "\033[1;31mSystem needs immediate attention!\033[0m"
        return 1
    elif [[ $warnings -gt 0 ]]; then
        echo -e "\033[1;33mSystem has some issues that should be addressed.\033[0m"
        return 1
    else
        echo -e "\033[1;32mSystem is healthy!\033[0m"
        return 0
    fi
}

# Main execution
run_health_checks
display_results
