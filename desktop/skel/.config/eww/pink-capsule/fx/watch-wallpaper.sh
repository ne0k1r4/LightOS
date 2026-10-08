#!/usr/bin/env bash

D="$HOME/.config/eww/pink-capsule"
SOURCE="$HOME/.config/waybar/wallpaper-colors.css"

last=""

while sleep 2; do
    [ -f "$SOURCE" ] || continue

    current=$(sha256sum "$SOURCE" | cut -d' ' -f1)

    if [ "$current" != "$last" ]; then
        last="$current"
        "$D/sync-colors.sh"
        python3 "$D/fx/sync-rofi-colors.py"
        "$D/visualizer/sync-color.sh"
        eww -c "$D" reload
    fi
done
