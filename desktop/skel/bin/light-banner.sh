#!/usr/bin/env bash

MAX_COLS=20   # max columns the banner may occupy
MAX_ROWS=10   # max rows the banner may occupy

image="$(find "$HOME/.config/Light/bash" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.gif' \) | shuf -n 1)"
[[ -n "$image" ]] || exit 0

[[ -t 1 && "$TERM" == "xterm-kitty" ]] || exit 0

ext="${image##*.}"
ext="${ext,,}"

# --- get terminal dimensions in cells ---
term_cols=$(tput cols)
term_rows=$(tput lines)

# --- get terminal cell pixel size ---
# kitty icat --print-window-size outputs one line: WIDTHxHEIGHT in pixels
cell_pw=0
cell_ph=0
win_px="$(kitty +kitten icat --print-window-size 2>/dev/null)"
if [[ -n "$win_px" && "$term_cols" -gt 0 && "$term_rows" -gt 0 ]]; then
    px_w="${win_px%%x*}"
    px_h="${win_px##*x}"
    if [[ "$px_w" -gt 0 && "$px_h" -gt 0 ]] 2>/dev/null; then
        cell_pw=$(( px_w / term_cols ))
        cell_ph=$(( px_h / term_rows ))
    fi
fi

# fallback: estimate from font_size in kitty.conf
if [[ "$cell_pw" -le 0 || "$cell_ph" -le 0 ]]; then
    font_size=$(grep -m1 'font_size' "$HOME/.config/kitty/kitty.conf" 2>/dev/null | awk '{print int($2)}')
    font_size=${font_size:-12}
    cell_pw=$(( font_size * 6 / 10 ))
    cell_ph=$(( font_size * 14 / 10 ))
fi

# --- get image pixel dimensions ---
img_pw=0
img_ph=0
if command -v identify >/dev/null 2>&1; then
    dims="$(identify -format '%w %h' "$image" 2>/dev/null | head -1)"
    img_pw="${dims%% *}"
    img_ph="${dims##* }"
fi
if [[ "$img_pw" -le 0 ]] && command -v python3 >/dev/null 2>&1; then
    dims="$(python3 -c "
from PIL import Image
img = Image.open('$image')
print(img.size[0], img.size[1])
" 2>/dev/null)"
    img_pw="${dims%% *}"
    img_ph="${dims##* }"
fi

# --- compute cell box ---
if [[ "$img_pw" -gt 0 && "$img_ph" -gt 0 && "$cell_pw" -gt 0 && "$cell_ph" -gt 0 ]]; then
    # try fitting to MAX_COLS wide
    fit_w_cols=$MAX_COLS
    fit_w_rows=$(( img_ph * fit_w_cols * cell_pw / (img_pw * cell_ph) ))

    # try fitting to MAX_ROWS tall
    fit_h_rows=$MAX_ROWS
    fit_h_cols=$(( img_pw * fit_h_rows * cell_ph / (img_ph * cell_pw) ))

    # use whichever fits within both limits
    if [[ "$fit_w_rows" -le "$MAX_ROWS" ]]; then
        box_w=$fit_w_cols
        box_h=$fit_w_rows
    else
        box_w=$fit_h_cols
        box_h=$fit_h_rows
    fi

    # clamp
    [[ "$box_w" -gt "$MAX_COLS" ]] && box_w=$MAX_COLS
    [[ "$box_h" -gt "$MAX_ROWS" ]] && box_h=$MAX_ROWS
    [[ "$box_w" -lt 6  ]] && box_w=6
    [[ "$box_h" -lt 4  ]] && box_h=4
else
    box_w=20
    box_h=10
fi

# --- display ---
if [[ "$ext" == "gif" ]]; then
    kitty +kitten icat --place "${box_w}x${box_h}@0x0" --align left --scale-up --loop -1 "$image" &
else
    kitty +kitten icat --place "${box_w}x${box_h}@0x0" --align left --scale-up "$image"
fi

tput cup "$box_h" 0 2>/dev/null || true
