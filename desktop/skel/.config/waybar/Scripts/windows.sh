#!/bin/bash
STYLE_CSS="$HOME/.config/waybar/style.css"
ICON_DIR="$HOME/.icons/LightOS/128/apps"

update_icon() {
    local icon_path="$1"
    sed -i "/#custom-game-icon {/ , /}/s|background-image: url('.*');|background-image: url('$icon_path');|" "$STYLE_CSS"
}

get_app_icon() {
    local window_class="$1"
    case "$window_class" in
        "com.moonlight_stream.Moonlight")
            echo "$ICON_DIR/moonlight.png"
            ;;
        "zen-browser")
            desktop_file=$(find ~/.local/share/applications/ -iname "*zen*.desktop" | head -n 1)
            if [ -f "$desktop_file" ]; then
                icon=$(grep -i "^Icon=" "$desktop_file" | cut -d '=' -f2)
                if [ -f "$HOME/.local/share/icons$icon" ]; then
                    echo "$HOME/.local/share/icons$icon"
                else
                    echo "$ICON_DIR/default.png"
                fi
            else
                echo "$ICON_DIR/default.png"
            fi
            ;;
        *)
            echo "$ICON_DIR/default.png"
            ;;
    esac
}

while true; do
    active_window_json=$(hyprctl activewindow -j)
    window_class=$(echo "$active_window_json" | jq -r '.class')
    icon_path=$(get_app_icon "$window_class")
    update_icon "$icon_path"
    sleep 2
done
