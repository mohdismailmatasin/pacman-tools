#!/bin/bash
# pacman-cleaner.sh: Clean Arch Linux system using pacman

echo "[0%] Starting system cleaning operations..."

# Display spinner function
display_spinner() {
  local message=$1
  (
    trap '' SIGTERM
    i=0
    spinner=('|' '/' '-' '\')
    while :; do
      printf "\r%s %s" "$message" "${spinner[$i%4]}"
      ((i=i+1))
      sleep 0.2
    done
  ) >/dev/null &
  echo $! # Return PID of spinner
}

# Stop spinner function
stop_spinner() {
  local spinner_pid=$1
  if [[ -n "$spinner_pid" ]]; then
    kill "$spinner_pid" >/dev/null 2>&1
    wait "$spinner_pid" 2>/dev/null
    printf "\r"
    tput el 2>/dev/null # Clear to end of line
  fi
}

# Ensure spinner stops on script exit or interruption
cleanup() {
  [[ -n "$spinner_pid" ]] && stop_spinner "$spinner_pid"
}
trap cleanup EXIT INT TERM

# 1. Clear pacman cache (keeping only the most recent version)
echo "[10%] Clearing pacman cache (keeping most recent versions)..."
spinner_pid=$(display_spinner "[10%] Clearing cache...")
if sudo pacman -Sc --noconfirm; then
  stop_spinner "$spinner_pid"
  echo "[30%] Pacman cache cleared"
else
  stop_spinner "$spinner_pid"
  echo "[30%] Warning: Failed to clear pacman cache"
fi

# 2. Remove orphaned packages
echo "[40%] Checking for orphaned packages..."
orphans=$(pacman -Qtdq 2>/dev/null)
if [[ -n "$orphans" ]]; then
  echo "[50%] Removing orphaned packages..."
  spinner_pid=$(display_spinner "[50%] Removing orphans...")
  if echo "$orphans" | sudo pacman -Rns --noconfirm -; then
    stop_spinner "$spinner_pid"
    echo "[60%] Orphaned packages removed"
  else
    stop_spinner "$spinner_pid"
    echo "[60%] Warning: Some orphaned packages could not be removed"
  fi
else
  echo "[60%] No orphaned packages found"
fi

# 3. Clean package cache completely (optional - removes all cached packages)
echo "[70%] Cleaning package cache completely..."
spinner_pid=$(display_spinner "[70%] Cleaning cache...")
if sudo pacman -Scc --noconfirm; then
  stop_spinner "$spinner_pid"
  echo "[80%] Package cache cleaned completely"
else
  stop_spinner "$spinner_pid"
  echo "[80%] Warning: Failed to clean package cache"
fi

# 4. Refresh package databases
echo "[90%] Refreshing package databases..."
spinner_pid=$(display_spinner "[90%] Refreshing databases...")
if sudo pacman -Sy; then
  stop_spinner "$spinner_pid"
  echo "[100%] Package databases refreshed"
else
  stop_spinner "$spinner_pid"
  echo "[100%] Warning: Failed to refresh package databases"
fi

echo ""
echo "[100%] System cleaning complete!"
echo "Summary of operations:"
echo "- Cleared pacman cache (kept most recent versions)"
echo "- Removed orphaned packages (if any)"
echo "- Cleaned package cache completely"
echo "- Refreshed package databases"
