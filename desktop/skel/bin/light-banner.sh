#!/usr/bin/env bash

BANNER_W=20
BANNER_H=10

image="$(find "$HOME/.config/Light/bash" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.gif' \) | shuf -n 1)"
[[ -n "$image" ]] || exit 0

[[ -t 1 && "$TERM" == "xterm-kitty" ]] || exit 0

ext="${image##*.}"
ext="${ext,,}"

if [[ "$ext" == "gif" ]]; then
    kitty +kitten icat --place "${BANNER_W}x${BANNER_H}@0x0" --align left --scale-up --loop -1 "$image" &
else
    kitty +kitten icat --place "${BANNER_W}x${BANNER_H}@0x0" --align left --scale-up "$image"
fi

tput cup "$BANNER_H" 0 2>/dev/null || true
