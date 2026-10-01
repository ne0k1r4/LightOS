#!/bin/bash
PACKAGES=("linux-zen" "linux-cachyos" "hyprland", "linux")
STATE_FILE="$HOME/.config/.checkupdates_notified"
touch "$STATE_FILE"
UPDATES=$(checkupdates 2>/dev/null)
FOUND_UPDATES=$(echo "$UPDATES" | grep -E "^($(IFS=\|; echo "${PACKAGES[*]}"))")
NEW_NOTIFICATIONS=()

while read -r UPDATE; do
    if [[ -n "$UPDATE" ]]; then
        PACKAGE=$(echo "$UPDATE" | awk '{print $1}')
        VERSION=$(echo "$UPDATE" | awk '{print $2}')
        STATE="$PACKAGE $VERSION"
        if ! grep -Fxq "$STATE" "$STATE_FILE"; then
            NEW_NOTIFICATIONS+=("$STATE")
            echo "$STATE" >> "$STATE_FILE"
        fi
    fi
done <<< "$FOUND_UPDATES"

if [[ ${#NEW_NOTIFICATIONS[@]} -gt 0 ]]; then
    NOTIFICATION="Updates available:\n$(printf "%s\n" "${NEW_NOTIFICATIONS[@]}")"
    echo -e "$NOTIFICATION"
    notify-send "Package Updates" "$NOTIFICATION" --icon=preferences-desktop-display
else
    echo "No new updates for specified packages."
fi
