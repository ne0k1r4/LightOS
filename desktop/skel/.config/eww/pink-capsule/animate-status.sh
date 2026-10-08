#!/usr/bin/env bash
case "${1:-}" in
  heart)
    case $(( $(date +%s%N | cut -c1-13) / 180 % 6 )) in
      0) printf '♡';; 1|5) printf '♥';; 2|4) printf '💗';; 3) printf '♥';;
    esac
    ;;
  disc)
    if [ "$(playerctl status 2>/dev/null)" = Playing ]; then
      frames=('◐' '◓' '◑' '◒')
      n=$(date +%s%N | cut -c1-13)
      printf '%s\n' "${frames[$(( n / 125 % 4 ))]}"
    else
      printf '◉\n'
    fi
    ;;
esac
