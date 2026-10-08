# LightOS Animated Capsule - Installation Notes

## What Changed

The LightOS desktop bar has been upgraded from Waybar to the LightOS Animated Capsule.

**New Default:** Eww-based animated floating capsule
**Fallback:** Waybar (still included, can be toggled)

## Package Requirements

The capsule requires `eww` which is available in AUR:

```bash
# Install eww (if not already installed)
yay -S eww
# or
paru -S eww
```

Other dependencies are already in the base LightOS install:
- gtk3
- gtk-layer-shell  
- playerctl
- python3
- nmcli (networkmanager)
- wpctl (pipewire)
- brightnessctl
- hyprctl

## Files Installed

- `~/.config/eww/pink-capsule/` - Full capsule configuration
- `~/bin/toggle-bar.sh` - Switch between capsule and waybar
- `~/bin/rollback-to-waybar.sh` - Permanently switch back to waybar

## Startup

The capsule launches automatically via `~/.config/hypr/auto_start.lua`:

```lua
hl.exec_cmd("~/.config/eww/pink-capsule/start.sh")
```

## Toggle Between Bars

Run: `~/bin/toggle-bar.sh`

Or add keybind in hyprland.conf:
```
bind = $mainMod SHIFT, B, exec, ~/bin/toggle-bar.sh
```

## Permanent Rollback to Waybar

Run: `~/bin/rollback-to-waybar.sh`

This will:
1. Stop the capsule
2. Update auto_start.lua to launch waybar
3. Start waybar immediately

## Customization

**Colors:** Edit `~/.config/eww/pink-capsule/_dynamic.scss`  
**Wallpaper sync:** Automatic via `sync-colors.sh`  
**Module actions:** Edit `~/.config/eww/pink-capsule/action.sh`  
**Polling intervals:** Edit `~/.config/eww/pink-capsule/eww.yuck`

## Troubleshooting

**Capsule not starting:**
```bash
# Check eww is installed
command -v eww

# Manual start
~/.config/eww/pink-capsule/start.sh

# Check logs
eww -c ~/.config/eww/pink-capsule logs
```

**Animation not working:**
```bash
# Check motion watcher
pgrep -f "motion.*watch"

# Restart capsule
pkill -f "eww.*pink-capsule"
~/.config/eww/pink-capsule/start.sh
```

**Colors not syncing:**
```bash
# Manually sync
~/.config/eww/pink-capsule/sync-colors.sh

# Check wallpaper colors exist
cat ~/.config/waybar/wallpaper-colors.css
```

## Reverting to Waybar

If you prefer the classic waybar:

**Option 1 - Temporary toggle:**
```bash
~/bin/toggle-bar.sh
```

**Option 2 - Permanent rollback:**
```bash
~/bin/rollback-to-waybar.sh
```

**Option 3 - Manual edit:**
Edit `~/.config/hypr/auto_start.lua` and swap the commented lines:
```lua
-- hl.exec_cmd("~/.config/eww/pink-capsule/start.sh")
hl.exec_cmd("waybar")
```

Then restart Hyprland or run `waybar &`
