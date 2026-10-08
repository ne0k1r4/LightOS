#!/usr/bin/env bash
D="$HOME/.config/eww/pink-capsule/visualizer"
# Cava outputs one semicolon-delimited frame per line.
# Eww's deflisten expects each line to be a JSON array.
exec cava -p "$D/cava.conf" 2>/tmp/lightos-cava.log | awk -F';' '
  NF >= 12 {
    printf "["
    for (i=1;i<=12;i++) {
      v=int($i+0); if(v<3)v=3; if(v>18)v=18;
      printf "%s%d", (i==1 ? "" : ","), v
    }
    print "]"
    fflush()
  }
'
