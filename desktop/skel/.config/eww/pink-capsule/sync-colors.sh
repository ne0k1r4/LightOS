#!/usr/bin/env bash
set -euo pipefail
D="$HOME/.config/eww/pink-capsule"
SRC="$HOME/.config/waybar/wallpaper-colors.css"
[ -f "$SRC" ] || exit 0
python3 - "$SRC" "$D/_dynamic.scss" <<'PY'
import re,sys
from pathlib import Path
s=Path(sys.argv[1]).read_text()
d={k:v for k,v in re.findall(r'@define-color\s+([\w-]+)\s+(#[0-9A-Fa-f]{3,8})\s*;',s)}
a=d.get('wallpaper_accent','#b881b8')
soft=d.get('wallpaper_accent_soft','#ffddf7')
ink=d.get('wallpaper_text','#fffaff')
def rgba(v,opacity):
    h=v.lstrip('#')
    if len(h)==3: h=''.join(x*2 for x in h)
    if len(h)<6: return 'rgba(184,129,184,0.88)'
    return f'rgba({int(h[:2],16)}, {int(h[2:4],16)}, {int(h[4:6],16)}, {opacity})'
Path(sys.argv[2]).write_text(
    f".pill {{ background-color: {rgba(a,0.88)}; border-color: {rgba(soft,0.65)}; }}\n"
    f".outer-heart {{ color: {soft}; }}\n"
    f".battery, .clock {{ color: {ink}; }}\n"
)
PY
