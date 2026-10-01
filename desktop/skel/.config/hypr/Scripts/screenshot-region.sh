#!/bin/bash
mkdir -p "$HOME/Pictures/Screenshots"
window=$(hyprctl activewindow | awk -F': ' '/initialClass:/ {print $2}' | xargs)
if [ -z "$window" ]; then
    window="Unknown"
fi
screenshot="$HOME/Pictures/Screenshots/$window$(date '+%y%m%d_%H-%M-%S').png"
if grim -g "$(slurp)" "$screenshot"; then
    wl-copy < "$screenshot"
    notify-send "LightOS" "$screenshot" --icon="$screenshot"
    gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.GetCapabilities | grep -q "actions" && wl-copy < "$screenshot"
else
    notify-send "Screenshot failed"
fi
