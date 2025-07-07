#!/bin/bash
# main.sh: Menu for Arch Linux maintenance scripts

SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while true; do
  clear
  echo "======================================="
  echo "    Arch Linux Maintenance Menu"
  echo "======================================="
  echo "1) System Update"
  echo "2) Pacman Cleaner"
  echo "3) Pacman Fixer"
  echo "4) System Health Check"
  echo "5) Package Information"
  echo "6) View Configuration"
  echo "7) Exit"
  echo "======================================="
  read -rp "Select an option [1-7]: " choice

  case $choice in
    1)
      bash "$SCRIPTDIR/arch-system-update.sh"
      read -rp "Press Enter to return to menu...";;
    2)
      bash "$SCRIPTDIR/pacman-cleaner.sh"
      read -rp "Press Enter to return to menu...";;
    3)
      bash "$SCRIPTDIR/pacman-fixer.sh"
      read -rp "Press Enter to return to menu...";;
    4)
      bash "$SCRIPTDIR/system-health-check.sh"
      read -rp "Press Enter to return to menu...";;
    5)
      bash "$SCRIPTDIR/package-info.sh"
      read -rp "Press Enter to return to menu...";;
    6)
      if [[ -f "$SCRIPTDIR/config.conf" ]]; then
        echo "Current configuration:"
        cat "$SCRIPTDIR/config.conf"
      else
        echo "No configuration file found. Using defaults."
      fi
      read -rp "Press Enter to return to menu...";;
    7)
      echo "Exiting."
      exit 0;;
    *)
      echo "Invalid option. Please try again."
      sleep 1;;
  esac
done
