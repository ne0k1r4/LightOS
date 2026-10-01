#!/usr/bin/env bash

STATE_FILE="/tmp/mpvpaper_state"
VIDEOS=(
    "$HOME/Videos/web/1000158176.mp4"
    "$HOME/Videos/web/meyro._kooo-20260515-0001.mp4"
    "$HOME/Videos/web/DEATH NOTE CATACLYSM [EditAMV].mp4"
    "$HOME/Videos/web/r3aa2e44v2j.mp4"
    "$HOME/Videos/web/night_lake.mp4"
)
COMMON="loop audio=auto volume=50 no-border keepaspect=no hwdec=auto"

state=0
[[ -f "$STATE_FILE" ]] && read -r state < "$STATE_FILE"
[[ "$state" =~ ^[0-4]$ ]] || state=0
video="${VIDEOS[$state]}"
next_state=$(((state + 1) % ${#VIDEOS[@]}))

if [[ ! -f "$video" ]]; then
    notify-send "LightOS" "Wallpaper video not found: ${video##*/}"
    exit 1
fi

pkill -x mpvpaper 2>/dev/null || true
sleep 0.25
mpvpaper -o "$COMMON" '*' "$video" &
printf '%s\n' "$next_state" > "$STATE_FILE"
python3 "$HOME/.config/waybar/Scripts/wallpaper-colors.py" "$video" >/dev/null 2>&1 || true
