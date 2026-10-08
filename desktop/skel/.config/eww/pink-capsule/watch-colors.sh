#!/usr/bin/env bash
D="$HOME/.config/eww/pink-capsule"
last=''
while sleep 3; do
 f="$HOME/.config/waybar/wallpaper-colors.css"
 [ -f "$f" ] || continue
 hash=$(sha256sum "$f" | cut -d' ' -f1)
 if [ "$hash" != "$last" ]; then
   last="$hash"
   "$D/sync-colors.sh"
   eww -c "$D" reload >/dev/null 2>&1 || true
 fi
done
