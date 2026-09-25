#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
RELENG="${ARCHISO_RELENG_PROFILE:-/usr/share/archiso/configs/releng}"
OUT_DIR="${LIGHTOS_ISO_OUT:-$ROOT/iso/out}"
PROFILE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/lightos-releng.XXXXXX")"
if [[ -n "${LIGHTOS_ISO_WORK:-}" ]]; then
    WORK_DIR="$LIGHTOS_ISO_WORK"
    mkdir -p "$WORK_DIR"
    CLEAN_WORK=false
else
    WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/lightos-work.XXXXXX")"
    CLEAN_WORK=true
fi
cleanup() {
    rm -rf -- "$PROFILE_DIR"
    if [[ "$CLEAN_WORK" == true ]]; then
        rm -rf -- "$WORK_DIR"
    fi
}
trap cleanup EXIT

if [[ "${EUID}" -eq 0 ]]; then
    echo "Run the ISO build as a regular user, not root." >&2
    exit 1
fi
command -v mkarchiso >/dev/null || { echo "Install archiso first: sudo pacman -S archiso" >&2; exit 1; }
[[ -d "$RELENG" ]] || { echo "Archiso releng profile not found: $RELENG" >&2; exit 1; }

mkdir -p "$OUT_DIR"
cp -a "$RELENG/." "$PROFILE_DIR/"

cat >> "$PROFILE_DIR/profiledef.sh" <<'PROFILE'

# LightOS profile identity
iso_name="lightos"
iso_label="LIGHTOS_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="LightOS Project"
iso_application="LightOS Arch Linux Installer"
PROFILE

{
    cat "$PROFILE_DIR/packages.x86_64"
    cat "$ROOT/iso/packages.x86_64" "$ROOT/packages/desktop.txt"
} | sed '/^[[:space:]]*#/d; /^[[:space:]]*$/d' \
    | awk '!seen[$0]++' > "$PROFILE_DIR/packages.x86_64.tmp"
mv "$PROFILE_DIR/packages.x86_64.tmp" "$PROFILE_DIR/packages.x86_64"

cp -a "$ROOT/iso/overlay/." "$PROFILE_DIR/airootfs/"

echo "Building LightOS ISO from the Archiso releng profile"
echo "Output: $OUT_DIR"
mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$PROFILE_DIR"
