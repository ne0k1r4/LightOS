#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
APPLY=false
WITH_GRUB=false
while (($#)); do
    case "$1" in
        --apply) APPLY=true ;;
        --with-grub) WITH_GRUB=true ;;
        -h|--help)
            printf 'Usage: %s [--apply] [--with-grub]\n\nWithout --apply, this script only prints the planned changes.\n--with-grub installs the included GRUB theme and regenerates grub.cfg.\n' "$0"
            exit 0
            ;;
        *) echo "Unknown option: $1" >&2; exit 2 ;;
    esac
    shift
done

if [[ ! -r /etc/arch-release ]]; then
    echo "LightOS currently supports Arch Linux only." >&2
    exit 1
fi

mapfile -t packages < <(sed '/^[[:space:]]*#/d; /^[[:space:]]*$/d' "$ROOT/packages/desktop.txt")
mapfile -d '' -t config_files < <(find "$ROOT/desktop/skel" -type f -print0)

printf 'Packages to install (%d):\n' "${#packages[@]}"
printf '  %s\n' "${packages[@]}"
printf 'User config files to copy (%d):\n' "${#config_files[@]}"
for source in "${config_files[@]}"; do
    printf '  %s\n' "${source#"$ROOT/desktop/skel/"}"
done

if [[ "$APPLY" == false ]]; then
    if [[ "$WITH_GRUB" == true ]]; then
        echo 'GRUB theme: system/grub/themes/LightOS -> /boot/grub/themes/LightOS'
        echo 'GRUB defaults will be backed up before GRUB_THEME is updated.'
        echo "Preview only. Re-run with --apply --with-grub to install everything shown."
    else
        echo "Preview only. Re-run with --apply to install packages and copy LightOS files."
    fi
    exit 0
fi

if [[ "$EUID" -eq 0 ]]; then
    echo "Run this script as your normal user." >&2
    exit 1
fi
command -v sudo >/dev/null || { echo "sudo is required." >&2; exit 1; }
command -v pacman >/dev/null || { echo "pacman is required." >&2; exit 1; }
for source in "${config_files[@]}"; do
    rel="${source#"$ROOT/desktop/skel/"}"
    target="$HOME/$rel"
    if [[ -d "$target" && ! -L "$target" ]]; then
        echo "Cannot replace a directory with a file: $target" >&2
        exit 1
    fi
done
install_prompt="Install LightOS packages, configuration, and components into $HOME?"
if [[ "$WITH_GRUB" == true ]]; then install_prompt+=" Include the GRUB theme and regenerate GRUB config?"; fi
read -r -p "$install_prompt [y/N] " answer
[[ "$answer" =~ ^[Yy]$ ]] || { echo "Cancelled."; exit 0; }

sudo pacman -S --needed "${packages[@]}"

backup="$HOME/.local/state/lightos/install-backups/$(date +%Y%m%d-%H%M%S)"
for source in "${config_files[@]}"; do
    rel="${source#"$ROOT/desktop/skel/"}"
    target="$HOME/$rel"
    if [[ -e "$target" || -L "$target" ]]; then
        if [[ -d "$target" && ! -L "$target" ]]; then
            echo "Cannot replace a directory with a file: $target" >&2
            exit 1
        fi
        mkdir -p "$backup/$(dirname "$rel")"
        cp -a "$target" "$backup/$rel"
    fi
    mkdir -p "$(dirname "$target")"
    cp -a --remove-destination "$source" "$target"
done

if [[ -d "$ROOT/components" ]]; then
    for component in LightOS-Assets LightOS-Downloader LightOS-Settings LightOS-Welcome LightOS-Launcher LightOS-Workspace LightOS-Widgets LightOS-Updater; do
        installer="$ROOT/components/$component/install.sh"
        if [[ -x "$installer" ]]; then
            echo "Installing $component"
            "$installer"
        fi
    done
fi



# LIGHTOS_VISUALIZER_ART_INSTALL
art_installer="$ROOT/components/LightOS-Assets/assets/visualizer/install.sh"

if [[ -f "$art_installer" ]]; then
    bash "$art_installer"
else
    echo "Visualizer artwork installer missing." >&2
    exit 1
fi

# LIGHTOS_HYBRID_VISUALIZER_INSTALL
hybrid_installer="$ROOT/components/LightOS-Widgets/visualizer/hybrid/install.sh"

if [[ -f "$hybrid_installer" ]]; then
    echo "Installing LightOS Hybrid Holographic Visualizer"
    bash "$hybrid_installer"
else
    echo "Hybrid visualizer source missing." >&2
    echo "Clone LightOS with --recurse-submodules." >&2
    exit 1
fi

if [[ "$WITH_GRUB" == true ]]; then
    echo 'Installing the optional LightOS GRUB theme.'
    "$ROOT/system/grub/install-theme.sh"
fi

if [[ -d "$backup" ]]; then
    echo "Previous files were saved under $backup"
fi
echo "LightOS desktop files installed. Review README.md for optional service setup."

# LIGHTOS_PILL_NOTIFICATIONS_SERVICE
# Enable the notification observer for the desktop user.
if [ -f "$HOME/.config/systemd/user/lightos-pill-notifications.service" ]; then
    if command -v systemctl >/dev/null 2>&1; then
        systemctl --user daemon-reload 2>/dev/null || true
        systemctl --user enable --now lightos-pill-notifications.service \
            2>/dev/null || true
    fi
fi

# LIGHTOS_NOTIFICATION_SOUND_INSTALL
notification_installer="$ROOT/components/LightOS-Assets/assets/notifications/install.sh"

if [[ -f "$notification_installer" ]]; then
    bash "$notification_installer"
else
    echo "Optional LightOS notification sound not found." >&2
fi
