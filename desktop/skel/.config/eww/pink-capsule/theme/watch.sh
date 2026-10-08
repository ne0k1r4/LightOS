#!/usr/bin/env bash
D="$HOME/.config/eww/pink-capsule"
P="$HOME/.config/waybar/wallpaper-colors.css"
last=""
while sleep 3; do
  [ -f "$P" ] || continue
  current=$(sha256sum "$P" | cut -d' ' -f1)
  [ "$current" = "$last" ] && continue
  last="$current"
  python3 "$D/theme/build.py" || continue
  eww -c "$D" reload >/tmp/lightos-popup-theme.log 2>&1 || true
done
