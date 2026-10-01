#!/bin/bash
TITLE=$(playerctl metadata title 2>/dev/null)
ARTIST=$(playerctl metadata artist 2>/dev/null)
ALBUM=$(playerctl metadata album 2>/dev/null)
COVER_URL=$(playerctl metadata mpris:artUrl 2>/dev/null)

if [[ -z "$TITLE" ]]; then
    echo "No song playing"
    exit
fi

echo "$TITLE" > /tmp/hyprlock_title.txt
echo "$ALBUM" > /tmp/hyprlock_album.txt

COVER_PATH="/tmp/hyprlock_cover.jpg"
if [[ "$COVER_URL" =~ ^file:// ]]; then
    cp "${COVER_URL#file://}" "$COVER_PATH"
else
    curl -sL "$COVER_URL" -o "$COVER_PATH"
fi

echo "$TITLE  $ARTIST"
