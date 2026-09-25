# LightOS

LightOS is a clean Arch Linux desktop project built around Hyprland. This repository provides two ways to install the same desktop layer:

1. Build and boot a LightOS Arch ISO, install Arch with `archinstall`, then run the LightOS setup.
2. Run the LightOS setup on an existing Arch Linux installation.

The project is in early development. The repo now contains a standalone desktop starter configuration and ISO build path. It is not a finished distribution release until it has been built and installed in a virtual machine and the remaining release checklist is complete.

## Build a bootable ISO

On an up-to-date Arch Linux build host:

```sh
sudo pacman -S --needed archiso
./iso/build-iso.sh
```

The image is written to `iso/out/`. Boot it and install Arch using `archinstall`. After booting into the installed system, clone this repository and run the setup script there.

## Install on existing Arch Linux

```sh
git clone <LightOS-repository-url>
cd LightOS
./install/install-lightos.sh       # preview only
./install/install-lightos.sh --apply
```

The setup script is preview-only by default. It installs packages from the official Arch repositories and copies the included Hyprland and Waybar starter config. It does not partition disks, format filesystems, or enable a display manager.

To use the graphical login on an installed system, enable services after reviewing the system's current setup:

```sh
sudo systemctl enable --now NetworkManager
sudo systemctl enable sddm
```

## Repository layout

- `desktop/skel/` — default user configuration installed into a home directory.
- `packages/` — packages shared by the ISO and existing-Arch setup.
- `install/` — additive desktop setup script.
- `iso/` — Archiso profile additions and ISO builder.
- `docs/` — release and maintenance notes.

## Hardware and support

The initial target is x86_64 Arch Linux. Hyprland requires a supported Wayland graphics setup. GPU-specific drivers, secure boot, disk encryption, non-Arch distributions, and automated disk installation are not configured by LightOS yet.
