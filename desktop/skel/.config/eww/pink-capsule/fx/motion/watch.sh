#!/usr/bin/env bash
D="$HOME/.config/eww/pink-capsule"
P="$HOME/.config/waybar/wallpaper-colors.css"
last=""
while sleep 3; do
 [ -f "$P" ] || continue
 now=$(sha256sum "$P" | cut -d' ' -f1)
 if [ "$now" != "$last" ]; then
   last="$now"
   python3 "$D/fx/motion/assets.py"
   eww -c "$D" reload
 fi
done
