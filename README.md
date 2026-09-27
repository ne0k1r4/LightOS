
# LightOS

LightOS is a clean Arch Linux desktop project built around Hyprland. This repository provides two ways to install the same desktop layer:

.
1. Run the LightOS setup on an existing Arch Linux installation.

The project is in early development. This is the main repository: component projects are pinned as Git submodules so one recursive clone fetches the complete source set. It is not a finished distribution release until it has been installed and verified in a virtual machine and the remaining release checklist is complete.

## Clone the complete source tree

```sh
git clone --recurse-submodules https://github.com/ne0k1r4/LightOS.git
cd LightOS
```

If you already cloned without submodules, run `git submodule update --init --recursive`.

## Build a bootable ISO

On an up-to-date Arch Linux build host:

```sh
sudo pacman -S --needed archiso
./iso/build-iso.sh
```

The image is written to `iso/out/`. Boot it and install Arch using `archinstall`. After booting into the installed system, clone this repository and run the setup script there.

## Install on existing Arch Linux

```sh
git clone --recurse-submodules https://github.com/ne0k1r4/LightOS.git
cd LightOS
./install/install-lightos.sh       # preview only
./install/install-lightos.sh --apply
# Add --with-grub to install the included GRUB theme and regenerate grub.cfg.
```

The setup script is preview-only by default. It installs packages from the official Arch repositories, copies the included desktop defaults, and builds/installs the available LightOS components, including Settings and the widgets suite (clock, visualizers, daemon, and clients). `--with-grub` adds the GRUB theme as an optional system-level step after confirmation. The setup does not partition disks, format filesystems, or enable a display manager.

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
- `components/` — pinned Settings, Welcome, Launcher, Workspace, Widgets, Updater, Downloader, and Assets projects.

After cloning recursively, `./install/install-lightos.sh --apply` installs the desktop configuration and available component apps from this single LightOS clone. Add `--with-grub` to include the GRUB theme. Each component's source is pinned as a submodule under `components/`.

## Hardware and support

The initial target is x86_64 Arch Linux. Hyprland requires a supported Wayland graphics setup. GPU-specific drivers, secure boot, disk encryption, non-Arch distributions, and automated disk installation are not configured by LightOS yet.
=======
# LightOS Launcher

A lightweight Wofi launcher command for LightOS. Desktop applications are discovered from the standard application index.

```sh
./install.sh
lightos-launcher
lightos-launcher run
lightos-launcher windows
```

Requires a Wayland session and Wofi. MIT licensed; see [LICENSE](LICENSE).

