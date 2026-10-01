hl.env("XCURSOR_THEME", "MisaDeathNote")
hl.env("XCURSOR_SIZE", "48")

hl.config({
    cursor = {
        enable_hyprcursor = false,
    },
})
require("variables")
require("applications")
require("app_keybinds")
require("auto_start")
require("window_rules")
require("variables2")

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
hl.monitor({ output = "", mode = "1920x1080@60", position = "0x0", scale = 1 })

hl.env("AQ_NO_EXPLICIT_SYNC", "1")
hl.env("vk_xwayland_wait_ready", "false")
hl.env("MESA_VK_WSI_PRESENT_MODE", "immediate")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("WLR_RENDERER", "vulkan")
hl.env("bitdepth", "10")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("CHROME_FLAGS", "--enable-features=UseOzonePlatform --ozone-platform=wayland")
hl.env("WLR_DRM_DEVICES", "/dev/dri/card2")
hl.env("LIBVA_DRIVER_NAME", "radeonsi")
hl.env("VDPAU_DRIVER", "radeonsi")

local mainMod = "ALT"
local mods = "ALT"

hl.bind("code:121", hl.dsp.exec_cmd("/home/LIGHT/.config/Light/bin/light-widget-daemon --mic mute"))
hl.bind("code:122", hl.dsp.exec_cmd("/home/LIGHT/.config/Light/bin/light-widget-daemon --volume down"))
hl.bind("code:123", hl.dsp.exec_cmd("/home/LIGHT/.config/Light/bin/light-widget-daemon --volume up"))
hl.bind("code:67",  hl.dsp.exec_cmd("/home/LIGHT/.config/Light/bin/light-widget-daemon --volume mute"))
hl.bind("code:72",  hl.dsp.exec_cmd("brightnessctl -d nvidia_wmi_ec_backlight set 5%-"))
hl.bind("code:73",  hl.dsp.exec_cmd("brightnessctl -d nvidia_wmi_ec_backlight set 5%+"))
hl.bind("code:232", hl.dsp.exec_cmd("brightnessctl -d nvidia_wmi_ec_backlight set 5%-"))
hl.bind("code:233", hl.dsp.exec_cmd("brightnessctl -d nvidia_wmi_ec_backlight set 5%+"))
hl.bind("code:237", hl.dsp.exec_cmd("brightnessctl -d asus::kbd_backlight set 33%-"))
hl.bind("code:238", hl.dsp.exec_cmd("brightnessctl -d asus::kbd_backlight set 33%+"))
hl.bind("code:148", hl.dsp.exec_cmd("subl"))
hl.bind("code:173", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("code:171", hl.dsp.exec_cmd("playerctl next"))
hl.bind("code:172", hl.dsp.exec_cmd("playerctl pause"))

hl.bind("SUPER + K", hl.dsp.exec_cmd("mpv --no-video --no-terminal --really-quiet --keep-open=no /home/LIGHT/.config/Light/sounds/lightos-hi.m4a"))

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))

for i = 1, 9 do
  hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
end

for i = 1, 9 do
  hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + 0", hl.dsp.workspace.toggle_special("light"))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = "special:light" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 10,  y = 0   }))
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.resize({ x = -10, y = 0   }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.resize({ x = 0,   y = -10 }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.resize({ x = 0,   y = 10  }))

hl.bind(mods .. " + N",         hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-wallpaper.sh"))
hl.bind(mods .. " + SHIFT + N", hl.dsp.exec_cmd("~/.config/hypr/scripts/stop-wallpaper.sh"))
