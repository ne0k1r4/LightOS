#!/usr/bin/env python3
from pathlib import Path
import re,sys
src=Path.home()/'.config/waybar/wallpaper-colors.css'
out=Path(sys.argv[1])
content=src.read_text() if src.exists() else ''
def get(name,default):
 m=re.search(r'@define-color\s+'+name+r'\s+(#[0-9a-fA-F]{6})\s*;',content)
 return m.group(1) if m else default
soft=get('wallpaper_accent_soft','#dfb6e6'); pale=get('wallpaper_accent_pale','#ffe8fa')
style=f'''/* LIGHTOS_FINAL_MOTION_PALETTE - generated, do not commit */
.capsule-spectrum-bar {{ background-color: {soft}; border: 1px solid {pale}; border-radius: 3px; min-width: 3px; }}
.capsule-spectrum {{ min-height: 22px; }}
'''
if not out.exists() or out.read_text()!=style: out.write_text(style)
print('Spectrum theme:',soft,pale)
