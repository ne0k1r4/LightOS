--[[
  Converted from auto_start.conf.
  exec-once= -> hl.exec_cmd() calls inside an hl.on("hyprland.start", ...) callback.
  https://wiki.hypr.land/Configuring/Basics/Autostart/
--]]

hl.on("hyprland.start", function()
  -- hl.exec_cmd("systemctl --user start wallpaper-auto.service")
  hl.exec_cmd("hyprctl setcursor 'LightOS-Cursor' 44")
  -- DROPPED: original had this same setcursor line twice (once as exec-once,
  -- once as plain exec) back to back -- redundant, collapsed to one call.

  hl.exec_cmd("~/.config/hypr/xdg-portal-hyprland")
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
  hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
  hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

  -- DROPPED: "exec-once = hyprctl reload" -- reloading config from inside its
  -- own startup sequence is redundant at best and can race/recurse at worst.
  -- Looked like a leftover debugging line; not carried over. Re-add manually
  -- if you actually rely on this for some reason.

  hl.exec_cmd("copyq --start-server")
  hl.exec_cmd("swaync")
  hl.exec_cmd("~/.config/eww/pink-capsule/start.sh")
  -- hl.exec_cmd("~/.config/hypr/autoruns.sh")  -- file missing, disabled
  hl.exec_cmd("~/.config/Light/bday/bday")

  -- Commented-out in original, kept inert here too:
  -- hl.exec_cmd("discord --enable-features=UseOzonePlatform --ozone-platform=wayland")
  -- hl.exec_cmd("steam -silent")
  -- hl.exec_cmd("kitty hyprctl plugin load ~/.local/share/hyprpm/Hyprspace/Hyprspace.so")
  -- hl.exec_cmd("systemctl restart bluetooth.service")

  hl.exec_cmd("~/.config/hypr/Scripts/album_waybar.sh")

  hl.exec_cmd("sh -c 'pgrep -x awww-daemon >/dev/null || awww-daemon'")

  hl.exec_cmd("gsr-ui")
  hl.exec_cmd("fcitx5")
  hl.exec_cmd("~/bin/ws-preview-recorder.sh")
  hl.exec_cmd("sh -c 'for i in $(seq 1 20); do awww query >/dev/null 2>&1 && break; sleep 0.5; done; wallpaper-switch.sh'")

  -- Commented-out swww one-liner in original, kept inert:
  -- hl.exec_cmd([[swww img --transition-type grow --transition-step 10 --transition-fps 60 "$(find ~/.config/Light/wallpaper -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | shuf -n 1)"]])

  hl.exec_cmd("/home/LIGHT/.config/Light/bin/light-widget-daemon")
  hl.exec_cmd("~/.config/Light/widgets/clock_widget")
  hl.exec_cmd("~/bin/welcome.sh")
end)

