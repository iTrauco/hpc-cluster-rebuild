#!/bin/bash
# Setup xbindkeys hotkey configuration on worker nodes

set -e

echo "=== Hotkey Setup Script ==="
echo "Target node: $(hostname)"
echo ""

echo "--- Installing xbindkeys ---"
sudo apt update
sudo apt install -y xbindkeys

echo "--- Creating directories ---"
mkdir -p ~/.config/autostart

echo "--- Creating xbindkeys configuration ---"
cat > ~/.xbindkeysrc << 'XBINDKEYS'
"~/scripts/chrome/claude1.sh"
  Control+Alt+1
"~/scripts/chrome/claude2.sh"
  Control+Alt+2
"~/scripts/chrome/claude3.sh"
  Control+Alt+3
"~/scripts/chrome/claude4.sh"
  Control+Alt+4
"~/scripts/chrome/claude-personal.sh"
  Control+Alt+5
"~/scripts/chrome/claude-dev.sh"
  Control+Alt+6
"~/scripts/chrome/openai-personal.sh"
  Control+Alt+7
"~/scripts/git/open-github-repo.sh"
  Shift+F6
"~/scripts/chrome/open_gmail.sh"
  Control+Alt+8
"~/scripts/chrome/open_linkedin.sh"
  Control+Alt+9
"~/scripts/chrome/open_gcp_trauco.sh"
  Control+Alt+0
"flameshot gui"
  Shift+F9
"~/display-fix/reset-displays.sh"
  Control+Alt+d
"~/display-fix/reset-displays.sh reboot"
  Control+Alt+r
"~/display-fix/reset-displays.sh reload-keys"
  Control+Alt+k
XBINDKEYS

echo "--- Creating autostart entry ---"
cat > ~/.config/autostart/xbindkeys.desktop << 'AUTOSTART'
[Desktop Entry]
Type=Application
Exec=xbindkeys
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=xbindkeys
AUTOSTART

echo "--- Starting xbindkeys ---"
pkill xbindkeys 2>/dev/null || true
xbindkeys

echo ""
echo "--- Verification ---"
if pgrep -x xbindkeys > /dev/null; then
    echo "✓ xbindkeys is running"
    echo "✓ Configuration created: ~/.xbindkeysrc"
    echo "✓ Autostart enabled: ~/.config/autostart/xbindkeys.desktop"
else
    echo "✗ xbindkeys failed to start"
    exit 1
fi

echo ""
echo "=== Setup Complete ==="
echo "NOTE: You must manually copy ~/scripts/ directory from source node"
echo "Hotkeys will be active after scripts are in place"
