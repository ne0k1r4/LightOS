#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
for dependency in g++ pkg-config; do
    command -v "$dependency" >/dev/null || {
        printf 'Missing build dependency: %s\n' "$dependency" >&2
        exit 1
    }
done
pkg-config --exists gtk+-3.0 gdk-3.0 gtk-layer-shell-0 || {
    echo 'Install GTK3 and gtk-layer-shell development packages first.' >&2
    exit 1
}

make -C "$ROOT"
BIN_DIR="${LIGHTOS_BIN_DIR:-$HOME/.config/Light/bin}"
ASSET_DIR="${LIGHTOS_LAUNCHER_ASSET_DIR:-$HOME/.config/Light/assets/launcher}"
install -d "$BIN_DIR" "$ASSET_DIR"
install -m 755 "$ROOT/light-launcher" "$BIN_DIR/light-launcher"
install -m 644 "$ROOT/assets/launcher/"*.png "$ASSET_DIR/"
printf 'Installed LightOS Launcher to %s\n' "$BIN_DIR/light-launcher"
printf 'Installed launcher artwork to %s\n' "$ASSET_DIR"
