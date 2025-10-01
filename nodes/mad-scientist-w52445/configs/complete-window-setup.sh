#!/bin/bash
# complete window management setup for ubuntu 24.04 nodes
# installs extensions and configures tiling plus cross-monitor movement

set -e

echo "step 1: ensure tiling assistant is enabled"
if ! gnome-extensions list --enabled | grep -q "tiling-assistant"; then
    gnome-extensions enable tiling-assistant@ubuntu.com
fi

echo "step 2: configure cross-monitor movement shift+arrows"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-down "['<Shift>Down']"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-left "['<Shift>Left']"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-right "['<Shift>Right']"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-up "['<Shift>Up']"

echo "step 3: import tiling assistant quadrant config from reference node"
if [ -f ~/tiling-assistant.dconf ]; then
    dconf load /org/gnome/shell/extensions/tiling-assistant/ < ~/tiling-assistant.dconf
    echo "tiling assistant config loaded"
else
    echo "warning: ~/tiling-assistant.dconf not found"
    echo "run this on reference node first:"
    echo "  dconf dump /org/gnome/shell/extensions/tiling-assistant/ > ~/tiling-assistant.dconf"
    echo "  scp ~/tiling-assistant.dconf <target>:~/"
    exit 1
fi

echo ""
echo "setup complete"
echo "log out and back in to apply changes"
echo ""
echo "test hotkeys:"
echo "  ctrl+1-4: quadrant tiling"
echo "  shift+arrows: move window across monitors"
