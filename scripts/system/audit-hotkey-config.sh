#!/bin/bash
# Audit hotkey configuration on a system
# Usage: ./audit-hotkey-config.sh

HOSTNAME=$(hostname)
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_DIR="$HOME/hpc-cluster-rebuild/diagnostics"
OUTPUT_FILE="$OUTPUT_DIR/hotkey-audit-${HOSTNAME}-${TIMESTAMP}.txt"

mkdir -p "$OUTPUT_DIR"

{
echo "=== Hotkey Configuration Audit ==="
echo "System: $HOSTNAME"
echo "Date: $(date)"
echo ""

echo "--- Process Check ---"
ps aux | grep -iE "xbindkeys|sxhkd|xhotkey" | grep -v grep
echo ""

echo "--- Config Files ---"
find ~ -maxdepth 3 \( -name ".xbindkeysrc" -o -name "*xbindkeys*" -o -name "*sxhkd*" \) -type f 2>/dev/null | while read f; do
    echo "Found: $f"
    echo "Size: $(stat -f%z "$f" 2>/dev/null || stat -c%s "$f" 2>/dev/null) bytes"
done
echo ""

echo "--- Script Directories ---"
for dir in ~/scripts ~/bin ~/display-fix; do
    if [ -d "$dir" ]; then
        echo "$dir exists"
        find "$dir" -type f -name "*.sh" | wc -l | xargs echo "  Shell scripts:"
    else
        echo "$dir MISSING"
    fi
done
echo ""

echo "--- Key Script Existence Check ---"
scripts=(
    "~/scripts/chrome/claude1.sh"
    "~/scripts/chrome/claude2.sh"
    "~/scripts/chrome/claude3.sh"
    "~/scripts/chrome/claude4.sh"
    "~/scripts/chrome/claude-personal.sh"
    "~/scripts/chrome/claude-dev.sh"
    "~/scripts/chrome/openai-personal.sh"
    "~/scripts/git/open-github-repo.sh"
    "~/scripts/chrome/open_gmail.sh"
    "~/scripts/chrome/open_linkedin.sh"
    "~/display-fix/reset-displays.sh"
    "~/bin/script-browser"
)
for script in "${scripts[@]}"; do
    expanded=$(eval echo "$script")
    if [ -f "$expanded" ]; then
        echo "✓ $script"
    else
        echo "✗ $script MISSING"
    fi
done
echo ""

echo "--- Autostart Check ---"
find ~/.config/autostart -name "*xbindkeys*" 2>/dev/null
echo ""

echo "=== Audit Complete ==="
} > "$OUTPUT_FILE"

echo "Audit written to: $OUTPUT_FILE"
cat "$OUTPUT_FILE"
