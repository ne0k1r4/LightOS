#!/bin/bash
THEME_STATE_DIR="$HOME/.config/hypr"
LIGHT_FILE="$THEME_STATE_DIR/Light.txt"
DARK_FILE="$THEME_STATE_DIR/Dark.txt"
HYPER_CONF="$HOME/.config/hypr/variables.lua"
VISUALIZER_LIGHT="$HOME/.config/Light/widgets/visualizer/light/visualizer"
VISUALIZER_DARK="$HOME/.config/Light/widgets/visualizer/dark/visualizer"

apply_light_theme() {
    sed -i 's/\["col.active_border"\]\s*=\s*"rgb([^"]*)"$/["col.active_border"]   = "rgb(eb71dc)"/' "$HYPER_CONF"
    kitty +kitten themes --reload-in=all "LightOS"
    hyprctl reload
    pkill -x light-widget-daemon
    ~/.config/Light/bin/light-widget-daemon --daemon >/dev/null 2>&1 &
    gsettings set org.gnome.desktop.interface gtk-theme "LightOS"
    gsettings set org.gnome.desktop.interface icon-theme "LightOS"
    gsettings set org.gnome.desktop.interface cursor-theme "LightOS-Cursor"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    rm -f "$DARK_FILE"
    choice=$(shuf -e "light" "cyrene" -n 1)
    echo "$choice" > "$LIGHT_FILE"
    ~/.config/Light/wallpaper/Light/l-wallpaper.sh
    pkill visualizer && "$VISUALIZER_LIGHT"
}

apply_dark_theme() {
    sed -i 's/\["col.active_border"\]\s*=\s*"rgb([^"]*)"$/["col.active_border"]   = "rgb(7077bd)"/' "$HYPER_CONF"
    kitty +kitten themes --reload-in=all "LightOS-HoC"
    hyprctl reload
    pkill -x light-widget-daemon
    ~/.config/Light/bin/light-widget-daemon --daemon >/dev/null 2>&1 &
    gsettings set org.gnome.desktop.interface gtk-theme "LightOS-HoC"
    gsettings set org.gnome.desktop.interface icon-theme "LightOS"
    gsettings set org.gnome.desktop.interface cursor-theme "LightOS-Cursor"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    rm -f "$LIGHT_FILE"
    touch "$DARK_FILE"
    ~/.config/Light/wallpaper/Dark/d-wallpaper.sh
    pkill visualizer && "$VISUALIZER_DARK"
}

if [[ -f "$LIGHT_FILE" ]]; then
    apply_dark_theme
else
    apply_light_theme
fi
