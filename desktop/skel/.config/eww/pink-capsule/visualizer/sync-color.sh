#!/usr/bin/env bash
D="$HOME/.config/eww/pink-capsule"
P="$HOME/.config/waybar/wallpaper-colors.css"
[ -f "$P" ] || exit 0
python3 - "$D/eww.scss" "$P" <<'PY'
from pathlib import Path
import re,sys
p=Path(sys.argv[1]); palette=Path(sys.argv[2]).read_text(); s=p.read_text()
m=re.search(r'@define-color\s+wallpaper_accent_soft\s+(#[0-9a-fA-F]{6})\s*;',palette)
color=m.group(1) if m else '#c9c1ba'
# Replace only the capsule visualizer bar color.
s=re.sub(r'(\.capsule-spectrum-bar\s*\{[^}]*?background-color:\s*)#[0-9a-fA-F]{6}',lambda x:x.group(1)+color,s,flags=re.S)
if s!=p.read_text(): p.write_text(s)
print('Visualizer accent:',color)
PY
