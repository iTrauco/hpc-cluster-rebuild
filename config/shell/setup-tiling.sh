#!/bin/bash
# Ubuntu GNOME Tiling Assistant Setup
# Replicates XFCE tiling workflow on vanilla Ubuntu Desktop

set -e

echo "Installing Tiling Assistant..."
cd /tmp
wget -q https://extensions.gnome.org/extension-data/tiling-assistantleleat-on-github.v46.shell-extension.zip
gnome-extensions install tiling-assistantleleat-on-github.v46.shell-extension.zip
gnome-extensions enable tiling-assistant@leleat-on-github

echo "Configuring quarter tiling (Ctrl+1-4)..."
gsettings set org.gnome.shell.extensions.tiling-assistant tile-topleft-quarter "['<Control>1']"
gsettings set org.gnome.shell.extensions.tiling-assistant tile-topright-quarter "['<Control>2']"
gsettings set org.gnome.shell.extensions.tiling-assistant tile-bottomleft-quarter "['<Control>3']"
gsettings set org.gnome.shell.extensions.tiling-assistant tile-bottomright-quarter "['<Control>4']"

echo "Configuring half-screen tiling (Super+Arrows)..."
gsettings set org.gnome.shell.extensions.tiling-assistant tile-top-half "['<Super>Up']"
gsettings set org.gnome.shell.extensions.tiling-assistant tile-bottom-half "['<Super>Down']"
gsettings set org.gnome.shell.extensions.tiling-assistant tile-left-half "['<Super>Left']"
gsettings set org.gnome.shell.extensions.tiling-assistant tile-right-half "['<Super>Right']"

echo "Configuring cross-monitor movement (Shift+Arrows)..."
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-left "['<Shift>Left']"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-right "['<Shift>Right']"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-up "['<Shift>Up']"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-down "['<Shift>Down']"

echo "Applying optimizations..."
gsettings set org.gnome.shell.extensions.tiling-assistant window-gap 10
gsettings set org.gnome.shell.extensions.tiling-assistant single-screen-gap 10
gsettings set org.gnome.shell.extensions.tiling-assistant enable-tiling-popup true
gsettings set org.gnome.shell.extensions.tiling-assistant enable-tile-animations false
gsettings set org.gnome.shell.extensions.tiling-assistant enable-untile-animations false

echo "✅ Tiling configuration complete!"
echo "Restart GNOME Shell: Alt+F2 → 'r' → Enter"
