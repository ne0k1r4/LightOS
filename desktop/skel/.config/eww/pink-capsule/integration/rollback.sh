#!/usr/bin/env bash
set -euo pipefail
D="$HOME/.config/eww/pink-capsule"
B="$(cat "$D/integration/backup-path")"
[ -d "$B" ] || { echo "Backup not found: $B"; exit 1; }
eww -c "$D" kill 2>/dev/null || true
cp -a "$B/." "$D/"
eww -c "$D" daemon
eww -c "$D" open capsule-window
echo "Restored $B"
