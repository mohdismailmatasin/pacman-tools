#!/bin/zsh
# pacman-fixer.sh: Scan and fix package file issues using pacman

# 1. Run pacman -Qkk and save output to log.txt
# Show spinner while running
( 
  i=0; 
  sp='|/-\'; 
  echo "[0%] Running pacman -Qkk and saving output to log.txt... (this may take several minutes)"; 
  while :; do 
    printf "\r[0%%] Checking packages... %s" "${sp:i++%${#sp}:1}"; 
    sleep 0.2; 
  done 
) &
SPIN_PID=$!
sudo pacman -Qkk > log.txt 2>&1
kill $SPIN_PID
wait $SPIN_PID 2>/dev/null
printf "\r[20%%] pacman -Qkk output saved to log.txt\n"

echo "[20%] Running pacman -Qkk and saving output to log.txt..."
sudo pacman -Qkk > log.txt 2>&1

echo "[20%] pacman -Qkk output saved to log.txt"

# 2. Scan log.txt for problems (mismatch, modification, missing, etc.)
echo "[30%] Scanning log.txt for issues..."
grep -E "(FAILED|warning|mismatch|missing|Modified)" log.txt > issues.txt

echo "[50%] Issues extracted to issues.txt"

# 3. Extract affected package names
# Get list of installed packages
pacman -Qq > installed_packages.txt

echo "[60%] Extracting affected package names..."
awk -F: '/FAILED|warning|mismatch|missing|Modified/ {print $1}' issues.txt | sort | uniq > all_found.txt
# Only keep valid package names
comm -12 <(sort all_found.txt) <(sort installed_packages.txt) > broken_packages.txt
rm all_found.txt installed_packages.txt

if [[ ! -s broken_packages.txt ]]; then
  echo "[100%] No broken packages found. System is healthy."
  exit 0
fi

echo "[70%] Packages to fix:"
cat broken_packages.txt

# 4. Reinstall affected packages
echo "[80%] Reinstalling affected packages..."
count=$(wc -l < broken_packages.txt)
current=0
while read pkg; do
  if [[ -n "$pkg" ]]; then
    current=$((current+1))
    percent=$((80 + (current * 20 / count)))
    echo "[$percent%] Reinstalling $pkg ($current/$count)..."
    sudo pacman -S --noconfirm "$pkg"
  fi
done < broken_packages.txt

echo "[100%] Done. Review log.txt and issues.txt for details."
