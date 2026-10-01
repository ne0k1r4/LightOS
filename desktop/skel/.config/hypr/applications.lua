local M = {}

M.browser  = "/usr/bin/zen-browser"
M.browser2 = "/usr/bin/tor-browser"
M.launcher3 = "~/.config/Light/bin/light-launcher"
M.texteditor  = "codium"
M.filemanager = "nemo"
M.terminal    = "kitty"
M.discord = "XDG_CURRENT_DESKTOP=Hyprland vesktop"
M.screenshot_region = "~/.config/hypr/Scripts/screenshot-region.sh"
M.screenshot_screen = "~/.config/hypr/Scripts/screenshot-full.sh"
M.light_widget_stats = "~/.config/Light/bin/light-widget-daemon --stats"
M.notifications       = "swaync-client -t"
M.wallpaper_menu = "~/.config/rofi/scripts/rofi-wallpaper.sh"
M.waybar_hide = [[sh -c "pkill waybar || waybar"]]
M.lang = "fcitx5-remote -n"

return M
