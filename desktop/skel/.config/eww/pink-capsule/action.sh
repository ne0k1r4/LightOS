#!/usr/bin/env bash
case "${1:-}" in
 music) playerctl play-pause 2>/dev/null || true;;
 next) playerctl next 2>/dev/null || true;;
 prev) playerctl previous 2>/dev/null || true;;
 wifi) "$HOME/.config/Light/bin/lightsettings" network >/dev/null 2>&1 & ;;
 bluetooth) if [ -x "$HOME/.config/rofi/scripts/bluetooth.sh" ]; then "$HOME/.config/rofi/scripts/bluetooth.sh" & else bluetoothctl show >/dev/null 2>&1 || true; fi;;
 volume) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle;;
 calendar) if command -v gnome-calendar >/dev/null; then gnome-calendar >/dev/null 2>&1 & else notify-send "$(date '+%A, %d %B %Y')"; fi;;
 settings) "$HOME/.config/Light/bin/lightsettings" >/dev/null 2>&1 & ;;
 notifications) swaync-client -t -sw;;
 workspace-next) hyprctl dispatch "hl.dsp.focus({workspace = 'e+1'})";;
 workspace-prev) hyprctl dispatch "hl.dsp.focus({workspace = 'e-1'})";;
esac
