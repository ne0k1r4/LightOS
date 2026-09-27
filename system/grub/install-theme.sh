#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
SOURCE="$ROOT/system/grub/themes/LightOS"
DEST="/boot/grub/themes/LightOS"

[[ -f /etc/default/grub ]] || { echo '/etc/default/grub was not found.' >&2; exit 1; }
command -v grub-mkconfig >/dev/null || { echo 'grub-mkconfig is required.' >&2; exit 1; }
[[ -f "$SOURCE/theme.txt" && -f "$SOURCE/background.png" ]] || { echo 'The LightOS GRUB theme files are incomplete.' >&2; exit 1; }

run_root() {
    if [[ "$EUID" -eq 0 ]]; then "$@"; else sudo "$@"; fi
}

backup="/etc/default/grub.lightos-backup.$(date +%Y%m%d%H%M%S)"
run_root cp -a /etc/default/grub "$backup"
run_root install -d -m 755 "$DEST"
while IFS= read -r -d '' file; do
    run_root install -m 644 "$file" "$DEST/${file##*/}"
done < <(find "$SOURCE" -maxdepth 1 -type f -print0)

run_root sed -i -E '/^[[:space:]]*GRUB_THEME=/d' /etc/default/grub
printf 'GRUB_THEME="%s/theme.txt"\n' "$DEST" | {
    if [[ "$EUID" -eq 0 ]]; then cat >> /etc/default/grub; else sudo tee -a /etc/default/grub >/dev/null; fi
}

if ! run_root grub-mkconfig -o /boot/grub/grub.cfg; then
    run_root cp -a "$backup" /etc/default/grub
    run_root grub-mkconfig -o /boot/grub/grub.cfg || true
    echo "GRUB configuration failed; /etc/default/grub was restored from $backup." >&2
    exit 1
fi

printf 'Installed the LightOS GRUB theme. Previous GRUB defaults are backed up at %s\n' "$backup"
