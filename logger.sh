#!/bin/bash
# logger.sh: Unified logging system for pacman-tools

# Source configuration
CONFIG_FILE="$(dirname "$0")/config.conf"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

# Default values if config not found
LOG_LEVEL=${LOG_LEVEL:-INFO}
LOG_FILE=${LOG_FILE:-"pacman-tools.log"}
BACKUP_LOGS=${BACKUP_LOGS:-true}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log levels
declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)
CURRENT_LOG_LEVEL=${LOG_LEVELS[$LOG_LEVEL]}

# Create log directory if it doesn't exist
LOG_DIR="$(dirname "$LOG_FILE")"
[[ ! -d "$LOG_DIR" ]] && mkdir -p "$LOG_DIR"

# Backup existing log if needed
if [[ "$BACKUP_LOGS" == "true" && -f "$LOG_FILE" ]]; then
    mv "$LOG_FILE" "${LOG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Logging functions
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local color=""
    
    case $level in
        DEBUG) color=$BLUE ;;
        INFO)  color=$GREEN ;;
        WARN)  color=$YELLOW ;;
        ERROR) color=$RED ;;
    esac
    
    # Check if we should log this level
    if [[ ${LOG_LEVELS[$level]} -ge $CURRENT_LOG_LEVEL ]]; then
        # Console output with color
        echo -e "${color}[$level]${NC} $message"
        
        # File output without color
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    fi
}

log_debug() { log_message "DEBUG" "$1"; }
log_info() { log_message "INFO" "$1"; }
log_warn() { log_message "WARN" "$1"; }
log_error() { log_message "ERROR" "$1"; }

# Error handling
handle_error() {
    local exit_code=$1
    local error_msg=$2
    log_error "$error_msg (Exit code: $exit_code)"
    exit $exit_code
}

# Progress tracking
show_progress() {
    local current=$1
    local total=$2
    local message=$3
    local percent=$((current * 100 / total))
    printf "\r[%d%%] %s" "$percent" "$message"
}

# Export functions for use in other scripts
export -f log_debug log_info log_warn log_error handle_error show_progress
