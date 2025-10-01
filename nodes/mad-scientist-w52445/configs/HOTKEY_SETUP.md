# Custom Hotkeys Configuration - xbindkeys Setup

## Overview
Automated setup of system-wide custom hotkeys using xbindkeys for HPC cluster worker nodes. Installs xbindkeys daemon, configures 15+ custom keyboard shortcuts, and enables autostart on boot.

### Chrome Profile Session Affinity
Hotkey scripts leverage Google Chrome's profile system to maintain separate browser sessions with isolated cookies, logins, and preferences. Each hotkey launches Chrome with a specific `--profile-directory` flag, ensuring URLs open in the correct authenticated context. For example, Ctrl+Alt+8 opens gmail.com in the personal Gmail profile, while work-related hotkeys use different profiles with their respective authenticated sessions. This eliminates manual profile switching and provides instant access to the correct account context system-wide.

## What This Does
1. Installs xbindkeys package via apt
2. Creates `~/.xbindkeysrc` configuration with all hotkey bindings
3. Creates autostart entry at `~/.config/autostart/xbindkeys.desktop`
4. Starts xbindkeys daemon immediately
5. Verifies successful installation and activation

## Hotkey Mappings

### Claude AI Profiles
- **Ctrl+Alt+1** → `~/scripts/chrome/claude1.sh`
- **Ctrl+Alt+2** → `~/scripts/chrome/claude2.sh`
- **Ctrl+Alt+3** → `~/scripts/chrome/claude3.sh`
- **Ctrl+Alt+4** → `~/scripts/chrome/claude4.sh`
- **Ctrl+Alt+5** → `~/scripts/chrome/claude-personal.sh`
- **Ctrl+Alt+6** → `~/scripts/chrome/claude-dev.sh`

### Other Services
- **Ctrl+Alt+7** → `~/scripts/chrome/openai-personal.sh`
- **Ctrl+Alt+8** → `~/scripts/chrome/open_gmail.sh`
- **Ctrl+Alt+9** → `~/scripts/chrome/open_linkedin.sh`
- **Ctrl+Alt+0** → `~/scripts/chrome/open_gcp_trauco.sh`

### Utilities
- **Shift+F6** → `~/scripts/git/open-github-repo.sh`
- **Shift+F9** → `flameshot gui` (screenshot tool)

### Display Management
- **Ctrl+Alt+d** → `~/display-fix/reset-displays.sh`
- **Ctrl+Alt+r** → `~/display-fix/reset-displays.sh reboot`
- **Ctrl+Alt+k** → `~/display-fix/reset-displays.sh reload-keys`

## Installation

### Prerequisites
- Ubuntu 24.04+ with sudo access
- `~/scripts/` directory with hotkey scripts (must be copied manually from source node)

### Single-Command Setup
From project root:
```bash
cd ~/hpc-cluster-rebuild
./nodes/mad-scientist-w52445/configs/setup-hotkeys.sh
```

### Post-Installation
After running setup script, manually copy scripts from source node using rsync or other file transfer method.

## Verification

### Check xbindkeys Status
```bash
# Is xbindkeys running?
pgrep -x xbindkeys

# View process details
ps aux | grep xbindkeys
```

### Run Diagnostic Script
```bash
cd ~/hpc-cluster-rebuild
./scripts/system/audit-hotkey-config.sh
```

Check output in `diagnostics/hotkey-audit-<hostname>-<timestamp>.txt`

### Test Hotkeys
- Press **Ctrl+Alt+1** → Should launch Claude profile 1
- Press **Shift+F9** → Should open Flameshot screenshot tool
- Press **Ctrl+Alt+d** → Should execute display reset script

## Troubleshooting

### Hotkeys Not Working
```bash
# Kill and restart xbindkeys
pkill xbindkeys
xbindkeys

# Run in verbose mode to see errors
xbindkeys -v
```

### Configuration Issues
```bash
# Verify config file exists
cat ~/.xbindkeysrc

# Check syntax
xbindkeys -k  # Press key combo to see keycode
```

### Scripts Not Executing
```bash
# Ensure scripts are executable
find ~/scripts -type f -name "*.sh" -exec chmod +x {} \;

# Test script manually
~/scripts/chrome/claude1.sh
```

### Autostart Not Working
```bash
# Verify autostart file exists
ls -la ~/.config/autostart/xbindkeys.desktop

# Check file contents
cat ~/.config/autostart/xbindkeys.desktop

# Restart system and verify
reboot
# After reboot:
pgrep -x xbindkeys
```

### Missing Scripts Error
If hotkeys trigger errors about missing scripts, you forgot to copy `~/scripts/` from source node.

## Configuration Files

### ~/.xbindkeysrc
Main configuration file defining all hotkey bindings. Format:
```
"command to execute"
  Key+Combination
```

### ~/.config/autostart/xbindkeys.desktop
Desktop entry that launches xbindkeys on login. Standard freedesktop autostart format.

## Manual Configuration

### Add New Hotkey
Edit `~/.xbindkeysrc`:
```bash
nano ~/.xbindkeysrc
```

Add entry:
```
"command"
  Key+Combo
```

Reload:
```bash
pkill xbindkeys && xbindkeys
```

### Find Key Codes
```bash
xbindkeys -k
# Press key combination to see code
```

### Disable Hotkey
Comment out in `~/.xbindkeysrc`:
```
#"~/scripts/chrome/claude1.sh"
#  Control+Alt+1
```

## For Future Nodes

When setting up worker node 3 or additional nodes:
1. Clone repo to new node
2. Run setup script from project root
3. Manually copy `~/scripts/` from source node
4. Run diagnostic to verify
5. Test all hotkeys