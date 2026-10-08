#!/usr/bin/env bash
D="$HOME/.config/eww/pink-capsule"
case "${1:-}" in
 enter)
   python3 -c 'import time; from pathlib import Path; (Path.home()/".config/eww/pink-capsule/fx/motion/start").write_text(str(time.monotonic()))'
   eww -c "$D" update expanded=true ;;
 leave) eww -c "$D" update expanded=false ;;
esac
