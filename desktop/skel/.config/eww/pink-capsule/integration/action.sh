#!/usr/bin/env bash
case "${1:-}" in
 logo) wlogout ;;
 logo-right) about_system ;;
 logo-middle) "$HOME/.config/Light/Theme.sh" ;;
 wallpaper) "$HOME/.config/Light/wallpaper/wallpaper.sh" ;;
 wallpaper-right) "$HOME/.config/Light/wallpaper/Light/l-rofi-wallpaper.sh" ;;
 special) hyprctl dispatch "hl.dsp.workspace.toggle_special('light')" ;;
 wifi) "$HOME/.config/Light/bin/lightsettings" network ;;
 wifi-right) if command -v network_manager >/dev/null; then network_manager; elif command -v nm-connection-editor >/dev/null; then nm-connection-editor; fi ;;
 bluetooth) "$HOME/.config/rofi/scripts/bluetooth.sh" ;;
 bluetooth-right) bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on ;;
 audio) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
 audio-up) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ ;;
 audio-down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
 audio-set) wpctl set-volume @DEFAULT_AUDIO_SINK@ "${2:-50}%" ;;
 bright-set) brightnessctl set "${2:-50}%" ;;
 bright-up) brightnessctl set 5%+ ;;
 bright-down) brightnessctl set 5%- ;;
 music) playerctl play-pause ;;
 music-right) "$HOME/.config/Light/bin/light-widget-daemon" --show ;;
 prev) playerctl previous ;;
 next) playerctl next ;;
 recorder) "$HOME/.config/waybar/Scripts/gpu-screen-record" ;;
 temp) if command -v kitty >/dev/null; then kitty -e sensors; fi ;;
 temp-right) kitty btop ;;
 settings) "$HOME/.config/Light/bin/lightsettings" ;;
 notifications) swaync-client -t -sw ;;
 notifications-right) swaync-client -d -sw ;;
 calendar) if command -v gnome-calendar >/dev/null; then gnome-calendar; else notify-send "$(date '+%A %d %B %Y')"; fi ;;
 workspace-prev) hyprctl dispatch "hl.dsp.focus({workspace = 'e-1'})" ;;
 workspace-next) hyprctl dispatch "hl.dsp.focus({workspace = 'e+1'})" ;;
 esac
