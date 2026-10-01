#!/bin/bash

SOCKET="/tmp/mpv-wallpaper.sock"

VIDEO1="$HOME/Downloads/Telegram/r3aa2e44v2j.mp4"
VIDEO2="$HOME/Downloads/Telegram/mm.mp4"
VIDEO3="$HOME/Downloads/Telegram/3jlmoyr1yk9.mp4"
VIDEO4="$HOME/Downloads/Telegram/BAACAgUAAxkBAAEBOjNp5o0XvJGCMQb7Glxg3VcM74qKowACxxsAAkXm_FQURThBSoW.mp4"
VIDEO5="$HOME/Downloads/Telegram/BAACAgUAAxkBAAEBqupqAAHBar9VdH721ePnU9MMng_N7PAAAmkbAAIcGNlXEyoumUe7KmseBA.mp4"
VIDEO6="$HOME/Downloads/Telegram/BAACAgUAAxkBAAJWWGoggk7bO8NtYYE7m3Anfo1h49W4AAJJHwACYNPpVod0Tc4ofpV6HgQ (2).mp4"

rm -f "$SOCKET"

python3 "$HOME/.config/waybar/Scripts/wallpaper-colors.py" "$VIDEO1" >/dev/null 2>&1 || true

mpvpaper -o "no-audio no-border keepaspect=no hwdec=auto loop-file=inf input-ipc-server=$SOCKET" "*" "$VIDEO1"
