#!/usr/bin/env bash
case "${1:-}" in
  temp) python3 - "$HOME/.config/waybar/Scripts/temps.sh" <<'PY'
import subprocess,json,sys
try:
 s=subprocess.run([sys.argv[1]],capture_output=True,text=True,timeout=3).stdout
 try: print(json.loads(s).get('text','--'))
 except: print(s.strip()[:30] or '--')
except: print('--')
PY
;;
  cpu) awk '/^cpu /{a=$2+$3+$4+$5+$6+$7+$8; b=$5; print a,b}' /proc/stat | awk '{print "CPU"}' ;;
  memory) free -h | awk '/^Mem:/ {print $3}' ;;
  window) hyprctl activewindow -j 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin).get("title","")[:35])' 2>/dev/null || true ;;
  bright) brightnessctl -m 2>/dev/null | awk -F, '{gsub(/%/,"",$4);print $4}' | head -1 ;;
  bluetooth) bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && echo ON || echo OFF ;;
  recorder) "$HOME/.config/waybar/Scripts/gpu_record.sh" 2>/dev/null | head -c 30 || true ;;
  artist) playerctl metadata --format '{{artist}}' 2>/dev/null | head -c 40 || true ;;
  network) nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | awk -F: '$1=="yes"{print substr($0,5);exit}' ;;
  *) echo -- ;;
esac
