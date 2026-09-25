#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
APPLY=false
case "${1:-}" in
    "") ;;
    --apply) APPLY=true ;;
    -h|--help)
        printf 'Usage: %s [--apply]\n\nWithout --apply, this script only prints the planned changes.\n' "$0"
        exit 0
        ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
esac

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
    echo "Preview only. Re-run with --apply to install packages and copy LightOS files."
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
read -r -p "Install LightOS packages and copy configuration into $HOME? [y/N] " answer
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

if [[ -d "$backup" ]]; then
    echo "Previous files were saved under $backup"
fi
echo "LightOS desktop files installed. Review README.md for optional service setup."
