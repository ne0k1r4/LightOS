# LightOS

A gothic anime Hyprland desktop for Arch Linux — Death Note themed, Misa Amane aesthetic, with a full suite of custom widgets, launchers, wallpapers, and icon themes.

![LightOS Desktop](desktop/skel/.config/hypr/welcoming/welcome.png)

## Install on Arch Linux

### Option 1 — From the ISO

1. Download the latest LightOS ISO from [Releases](https://github.com/ne0k1r4/LightOS/releases)
2. Flash it to a USB drive:
   ```sh
   dd if=lightos.iso of=/dev/sdX bs=4M status=progress && sync
   ```
3. Boot from USB, install Arch with `archinstall`, then run the desktop installer:
   ```sh
   curl -fsSL https://raw.githubusercontent.com/ne0k1r4/LightOS/main/install/install-lightos.sh | bash
   ```

### Option 2 — On an existing Arch Linux system

Clone the repository with all components:
```sh
git clone --recurse-submodules https://github.com/ne0k1r4/LightOS.git
cd LightOS
```

Run the installer:
```sh
bash install/install-lightos.sh --apply
```

Optionally install the LightOS GRUB theme:
```sh
bash install/install-lightos.sh --apply --with-grub
```

That's it. The installer sets up Hyprland, Waybar, all widgets, wallpapers, icons, fonts, and shell config. Log out and select Hyprland from your display manager.

## Requirements

- Arch Linux (fresh install recommended)
- Internet connection during install
- No other desktop environment required

## What's included

| Component | Description |
|---|---|
| Hyprland config | Lua-based, fully commented, keybinds, rules, animations |
| Waybar | Wallpaper-driven color palette, custom icons, media/stats modules |
| Light Launcher | GTK3 app launcher with emoji, GIF, file search, wallpaper picker |
| Clock Widget | Hour-based artwork display, gothic themed |
| Workspace Switcher | Death Note spine layout with dynamic glow colors |
| Audio Visualizer | Wave+fill style, wallpaper-color driven |
| LightOS Settings | GTK4 system settings app |
| Icon Theme | Gothic anime PNG mime, app, and status icons |
| Wallpapers | Dark and Light sets, images and videos |
| Terminal Banner | Random gothic artwork at shell startup |

## Keybinds (defaults)

| Key | Action |
|---|---|
| `Super + T` | Open terminal (kitty) |
| `Super + L` | Open launcher |
| `Super + Tab` | Workspace switcher |
| `Super + Shift + W` | Wallpaper picker |
| `Super + Q` | Close window |
| `Super + 1–9` | Switch workspace |

## Components

Each component is a standalone repository and Git submodule:

- [LightOS-Assets](https://github.com/ne0k1r4/LightOS-Assets) — icons, wallpapers, bash banners
- [LightOS-Launcher](https://github.com/ne0k1r4/LightOS-Launcher) — GTK3 app launcher
- [LightOS-Widgets](https://github.com/ne0k1r4/LightOS-Widgets) — clock, visualizer, widget suite
- [LightOS-Workspace](https://github.com/ne0k1r4/LightOS-Workspace) — workspace switcher
- [LightOS-Settings](https://github.com/ne0k1r4/LightOS-Settings) — GTK4 settings app
- [LightOS-Installer](https://github.com/ne0k1r4/LightOS-Installer) — bootstrap and install scripts

## License

MIT — see [LICENSE](LICENSE). Component licenses retained in their respective repositories.
