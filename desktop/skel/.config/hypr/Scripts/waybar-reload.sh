#!/bin/bash
THEME_STATE_DIR="$HOME/.config/hypr"
WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
WAYBAR_DARK_STYLE="$HOME/.config/waybar/Dark/style.css"
WAYBAR_DARK_CONFIG="$HOME/.config/waybar/Dark/config.jsonc"

kill_waybar() {
    while pgrep -x "waybar" > /dev/null; do
        pkill -x "waybar"
        sleep 0.4
    done
}

kill_waybar

if [[ -f "$THEME_STATE_DIR/Dark.txt" && ! -f "$THEME_STATE_DIR/Light.txt" ]]; then
    waybar -c "$WAYBAR_DARK_CONFIG" -s "$WAYBAR_DARK_STYLE" & disown
elif [[ -f "$THEME_STATE_DIR/Light.txt" && ! -f "$THEME_STATE_DIR/Dark.txt" ]]; then
    waybar -c "$WAYBAR_CONFIG" & disown
else
    waybar -c "$WAYBAR_CONFIG" & disown
fi
