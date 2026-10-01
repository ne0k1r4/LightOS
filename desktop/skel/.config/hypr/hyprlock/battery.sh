#!/bin/bash
if [ "$1" == "-bat" ]; then
    battery_path=""
    for bat in /sys/class/power_supply/BAT*; do
        if [ -d "$bat" ] && [ -f "$bat/capacity" ] && [ -f "$bat/status" ]; then
            battery_path="$bat"
            break
        fi
    done
    if [ -z "$battery_path" ]; then
        echo "No battery found"
        exit 1
    fi
    battery_percentage=$(cat "$battery_path/capacity")
    battery_status=$(cat "$battery_path/status")
    battery_icons=("󱉝" "󱊡" "󱊡" "󱊡" "󱊢" "󱊢" "󱊢" "󱊢" "󱊢" "󱊣")
    charging_icon="󰂄"
    icon_index=$((battery_percentage / 10))
    [ $icon_index -gt 9 ] && icon_index=9
    battery_icon=${battery_icons[icon_index]}
    [ "$battery_status" = "Charging" ] && battery_icon="$charging_icon"
    echo "$battery_percentage%$battery_icon"
else
    echo "Invalid option: $1"
    echo "Usage: $0 -bat"
    exit 1
fi
