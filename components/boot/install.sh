#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$ROOT/lightos-boot"
NAME="lightos-v12-crimson-ink"
DEST="/usr/share/plymouth/themes/$NAME"

if [[ $EUID -ne 0 ]]; then
    echo "Run with sudo: sudo ./install.sh"
    exit 1
fi

command -v plymouth-set-default-theme >/dev/null ||
    { echo "Plymouth is not installed"; exit 1; }

command -v mkinitcpio >/dev/null ||
    { echo "mkinitcpio is not installed"; exit 1; }

[[ -f "$SRC/$NAME.plymouth" ]] ||
    { echo "Theme definition missing"; exit 1; }

[[ -f "$SRC/$NAME.script" ]] ||
    { echo "Theme script missing"; exit 1; }

mkdir -p "$DEST"
cp -a "$SRC/." "$DEST/"

echo "LightOS boot animation installed at $DEST"
echo "Current Plymouth theme was not changed."
echo
echo "To activate:"
echo "  sudo plymouth-set-default-theme $NAME"
echo "  sudo mkinitcpio -P"
