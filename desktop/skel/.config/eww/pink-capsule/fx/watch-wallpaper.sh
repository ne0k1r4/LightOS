#!/usr/bin/env bash

D="$HOME/.config/eww/pink-capsule"
P="$HOME/.config/waybar/wallpaper-colors.css"

last=""

while sleep 3; do
    [ -f "$P" ] || continue

    current=$(sha256sum "$P" | cut -d' ' -f1)

    if [ "$current" != "$last" ]; then
        last="$current"
        python3 "$D/fx/wallpaper-ray.py"
        eww -c "$D" reload
    fi
done
