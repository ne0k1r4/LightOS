#!/usr/bin/env bash
D="$HOME/.config/eww/pink-capsule"
STATE="$D/.motion-state"
MODE="${1:-leave}"
# Latest hover event wins, even when earlier stagger jobs are sleeping.
TOKEN="$(date +%s%N)-$$"
printf '%s\n' "$TOKEN" > "$STATE"
apply() {
  [ "$(cat "$STATE" 2>/dev/null)" = "$TOKEN" ] || exit 0
  eww -c "$D" update "$@" >/dev/null 2>&1 || true
}
if [ "$MODE" = enter ]; then
  apply expanded=true show_left=false show_right=false show_media=false
  sleep 0.075
  apply show_left=true
  sleep 0.095
  apply show_right=true
  sleep 0.090
  apply show_media=true
else
  apply show_media=false show_right=false show_left=false
  sleep 0.16
  apply expanded=false
fi
