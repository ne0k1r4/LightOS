#!/usr/bin/env bash
D="$HOME/.config/eww/pink-capsule"
mode="${1:-toggle}"; window="${2:-controls-popup}"
case "$window" in controls-popup|dashboard-popup) ;; *) exit 1;; esac
case "$mode" in
 close)
  eww -c "$D" update panel-details=false panel-reveal=false
  (sleep 0.30; eww -c "$D" close "$window" >/dev/null 2>&1) &
  ;;
 toggle|open)
  if [ "$mode" = toggle ] && eww -c "$D" active-windows 2>/dev/null | grep -q "$window"; then
    "$D/panel.sh" close "$window"
    exit 0
  fi
  eww -c "$D" update panel-reveal=false panel-details=false
  eww -c "$D" open "$window"
  (sleep 0.05; eww -c "$D" update panel-reveal=true; sleep 0.15; eww -c "$D" update panel-details=true) &
  ;;
esac
