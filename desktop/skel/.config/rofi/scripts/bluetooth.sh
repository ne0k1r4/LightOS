#!/bin/bash

# LIGHTOS_CAPSULE_ROFI_FIX
rofi() {
    command rofi "$@" \
      -theme "$HOME/.config/rofi/themes/lightos-capsule.rasi" \
      -theme-str 'window { location: north; anchor: north; x-offset: 0px; y-offset: 58px; width: 310px; }'
}

BT_POWER=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')

if [ "$BT_POWER" = "no" ]; then
    TOGGLE="⏻  Enable Bluetooth"
else
    TOGGLE="⏻  Disable Bluetooth"
fi

CONNECTED=$(bluetoothctl devices Connected | while read -r _ mac name; do
    echo "󰂲  Disconnect: $name"
done)

ALL=$(bluetoothctl devices | while read -r _ mac name; do
    if ! bluetoothctl info "$mac" | grep -q "Connected: yes"; then
        echo "󰂯  Connect: $name"
    fi
done)

OPTIONS="$TOGGLE\n󰂰  Scan for devices"
[ -n "$CONNECTED" ] && OPTIONS="$OPTIONS\n$CONNECTED"
[ -n "$ALL" ]       && OPTIONS="$OPTIONS\n$ALL"

CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu \
    -theme ~/.config/rofi/bluetooth/themes/transparent.rasi \
    -i -no-history -matching fuzzy -no-tokenize -hover-select)

[ -z "$CHOICE" ] && exit

if [[ "$CHOICE" == *"Enable Bluetooth"* ]]; then
    bluetoothctl power on
    notify-send "Bluetooth" "Enabled 󰂯"
elif [[ "$CHOICE" == *"Disable Bluetooth"* ]]; then
    bluetoothctl power off
    notify-send "Bluetooth" "Disabled 󰂲"
elif [[ "$CHOICE" == *"Scan"* ]]; then
    notify-send "Bluetooth" "Scanning for 8 seconds..."
    bluetoothctl scan on & sleep 8; kill $!; bluetoothctl scan off
    notify-send "Bluetooth" "Scan complete. Reopen to connect."
elif [[ "$CHOICE" == *"Connect:"* ]]; then
    NAME=$(echo "$CHOICE" | sed 's/.*Connect: //')
    MAC=$(bluetoothctl devices | grep "$NAME" | awk '{print $2}')
    bluetoothctl connect "$MAC" && notify-send "Bluetooth" "Connected to $NAME 󰂱"
elif [[ "$CHOICE" == *"Disconnect:"* ]]; then
    NAME=$(echo "$CHOICE" | sed 's/.*Disconnect: //')
    MAC=$(bluetoothctl devices | grep "$NAME" | awk '{print $2}')
    bluetoothctl disconnect "$MAC" && notify-send "Bluetooth" "Disconnected from $NAME"
fi
