#!/bin/bash
# toggle between capsule and waybar

if pgrep -f "eww.*pink-capsule" >/dev/null; then
    # capsule running, switch to waybar
    eww -c ~/.config/eww/pink-capsule close capsule-window 2>/dev/null
    pkill -f "eww.*pink-capsule"
    sleep 0.5
    waybar &
    notify-send "LightOS Bar" "Switched to Waybar"
else
    # waybar running, switch to capsule
    pkill waybar
    sleep 0.5
    ~/.config/eww/pink-capsule/start.sh
    notify-send "LightOS Bar" "Switched to Capsule"
fi
