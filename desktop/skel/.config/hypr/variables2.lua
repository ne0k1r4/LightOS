hl.config({
  input = {
    kb_layout = "us",
    follow_mouse = 1,
    touchpad = {
      natural_scroll = false,
    },
    sensitivity = 0,
    numlock_by_default = true,
  },

  misc = {
    disable_hyprland_logo = true,
    enable_anr_dialog = false,
  },

  decoration = {
    rounding = 16,
    blur = {
      enabled = true,
      size = 3,
      passes = 3,
      new_optimizations = true,
    },
    shadow = {
      enabled = true,
      render_power = 4,
      range = 7,
      color = "rgba(1a1a1aee)",
    },
  },

  dwindle = {
    preserve_split = true,
  },

  master = {
    new_status = 1,
  },
})

hl.curve("overshot", { type = "bezier", points = { {0.13, 0.99}, {0.29, 1.1} } })

hl.animation({ leaf = "windows",     enabled = true, speed = 7,  bezier = "overshot", style = "slide" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7,  bezier = "default",  style = "popin 30%" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 4,  bezier = "overshot", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4,  bezier = "overshot", style = "slide" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,  bezier = "overshot", style = "slidefade" })
