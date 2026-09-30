#!/usr/bin/env bash

MAX_W_FRAC=40   # max % of terminal columns the banner may occupy
MAX_H_FRAC=40   # max % of terminal rows the banner may occupy

image="$(find "$HOME/.config/Light/bash" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.gif' \) | shuf -n 1)"
[[ -n "$image" ]] || exit 0

[[ -t 1 && "$TERM" == "xterm-kitty" ]] || exit 0

ext="${image##*.}"
ext="${ext,,}"

# --- get terminal dimensions in cells ---
term_cols=$(tput cols)
term_rows=$(tput lines)

# --- get terminal cell pixel size via kitty icat ---
# Output format: "WpxHp\nCcxRc"  (pixels then cells)
cell_pw=0
cell_ph=0
win_info="$(kitty +kitten icat --print-window-size 2>/dev/null)"
if [[ -n "$win_info" ]]; then
    px_line="$(echo "$win_info" | head -1)"   # e.g. 1920x1080
    cell_line="$(echo "$win_info" | tail -1)" # e.g. 192x54
    px_w="${px_line%%x*}"; px_h="${px_line##*x}"
    cl_w="${cell_line%%x*}"; cl_h="${cell_line##*x}"
    if [[ "$cl_w" -gt 0 && "$cl_h" -gt 0 ]] 2>/dev/null; then
        cell_pw=$(( px_w / cl_w ))
        cell_ph=$(( px_h / cl_h ))
    fi
fi

# fallback: estimate cell size from font_size in kitty.conf
if [[ "$cell_pw" -le 0 || "$cell_ph" -le 0 ]]; then
    font_size=$(grep -m1 'font_size' "$HOME/.config/kitty/kitty.conf" 2>/dev/null | awk '{print int($2)}')
    font_size=${font_size:-12}
    cell_pw=$(( font_size * 6 / 10 ))   # ~0.6x font_size
    cell_ph=$(( font_size * 14 / 10 ))  # ~1.4x font_size (line height)
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
max_cols=$(( term_cols * MAX_W_FRAC / 100 ))
max_rows=$(( term_rows * MAX_H_FRAC / 100 ))

# ensure minimum of 10 cols / 5 rows
[[ "$max_cols" -lt 10 ]] && max_cols=10
[[ "$max_rows" -lt 5  ]] && max_rows=5

if [[ "$img_pw" -gt 0 && "$img_ph" -gt 0 && "$cell_pw" -gt 0 && "$cell_ph" -gt 0 ]]; then
    # scale to fit within max_cols x max_rows, preserving aspect ratio
    # fit by width
    fit_w_cols=$max_cols
    fit_w_rows=$(( img_ph * fit_w_cols * cell_pw / (img_pw * cell_ph) ))

    # fit by height
    fit_h_rows=$max_rows
    fit_h_cols=$(( img_pw * fit_h_rows * cell_ph / (img_ph * cell_pw) ))

    # pick whichever fits both dimensions
    if [[ "$fit_w_rows" -le "$max_rows" ]]; then
        box_w=$fit_w_cols
        box_h=$fit_w_rows
    else
        box_w=$fit_h_cols
        box_h=$fit_h_rows
    fi

    # clamp to bounds
    [[ "$box_w" -gt "$max_cols" ]] && box_w=$max_cols
    [[ "$box_h" -gt "$max_rows" ]] && box_h=$max_rows
    [[ "$box_w" -lt 1 ]] && box_w=1
    [[ "$box_h" -lt 1 ]] && box_h=1
else
    # fallback fixed size
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
