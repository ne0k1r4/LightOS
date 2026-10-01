#!/bin/bash
mkdir -p "$HOME/Pictures/Screenshots"
window=$(hyprctl activewindow | awk -F': ' '/initialClass:/ {print $2}' | xargs)
if [ -z "$window" ]; then
    window="Unknown"
fi
screenshot="$HOME/Pictures/Screenshots/$window$(date '+%y%m%d_%H-%M-%S').png"
grim "$screenshot" && wl-copy < "$screenshot"
notify-send "LightOS" "$screenshot" --icon="$screenshot"
