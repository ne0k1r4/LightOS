#!/usr/bin/env bash
case "${1:-}" in
 clock) date '+%I:%M %p';;
 battery) for f in /sys/class/power_supply/BAT*/capacity; do if [ -r "$f" ]; then cat "$f"; exit; fi; done; echo '--';;
 batteryclass) for f in /sys/class/power_supply/BAT*/status; do if [ -r "$f" ]; then cat "$f"; exit; fi; done; echo Unknown;;
 volume) wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{printf "%.0f\n",$2*100}' || echo 0;;
 wifi) nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | awk -F: '$1=="yes" {print substr($0,5); found=1;exit} END {if(!found) print "Offline"}' ;;
 music) playerctl status 2>/dev/null || echo Stopped;;
 title) playerctl metadata --format '{{title}}' 2>/dev/null | head -c 45 || true;;
 workspace) hyprctl activeworkspace -j 2>/dev/null | python3 -c 'import sys,json; print(json.load(sys.stdin).get("id",1))' 2>/dev/null || echo 1;;
 *) echo '';;
esac
