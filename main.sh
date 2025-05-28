#!/bin/bash
# main.sh: Menu for Arch Linux maintenance scripts

SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while true; do
  clear
  echo "==============================="
  echo " Arch Linux Maintenance Menu"
  echo "==============================="
  echo "1) System Update"
  echo "2) Pacman Cleaner"
  echo "3) Pacman Fixer"
  echo "4) Exit"
  echo "==============================="
  read -rp "Select an option [1-4]: " choice

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
      echo "Exiting."
      exit 0;;
    *)
      echo "Invalid option. Please try again."
      sleep 1;;
  esac
done
