#!/usr/bin/env bash
set -e
D="$HOME/.config/eww/pink-capsule"
"$D/sync-colors.sh"
eww -c "$D" daemon
eww -c "$D" update expanded=false
eww -c "$D" open capsule-window
