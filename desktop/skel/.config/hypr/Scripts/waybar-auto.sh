#!/bin/bash
STATE_FILE="/tmp/waybar_toggle_state"

if [[ -f $STATE_FILE ]]; then
    pkill -SIGUSR2 waybar
    rm $STATE_FILE
else
    pkill -SIGUSR1 waybar
    touch $STATE_FILE
fi
