#!/usr/bin/env python3
import re
from pathlib import Path
h=Path.home(); d=h/'.config/eww/pink-capsule'
s=(h/'.config/waybar/wallpaper-colors.css').read_text()
def get(n, default):
    m=re.search(r'@define-color\s+'+re.escape(n)+r'\s+(#[0-9a-fA-F]{3,8})\s*;',s)
    return m.group(1) if m else default
def rgba(hexval,a):
    t=hexval.lstrip('#')
    if len(t) in (3,4): t=''.join(x*2 for x in t)
    return 'rgba('+','.join(str(int(t[i:i+2],16)) for i in (0,2,4))+f',{a})'
accent=get('wallpaper_accent','#b884b8')
soft=get('wallpaper_accent_soft','#ffd8f5')
deep=get('wallpaper_accent_deep','#503455')
ink=get('wallpaper_ink','#211c2b')
fg=get('wallpaper_text','#ffffff')
# Only style popups/panels. Capsule animations and geometry are untouched.
css=f'''/* GENERATED from LightOS wallpaper-colors.css; do not edit */
.light-panel, .popup, .control-center, .dashboard-panel {{
  background-color: {rgba(ink,.93)};
  color: {fg};
  border: 1px solid {rgba(soft,.76)};
  border-radius: 22px;
  box-shadow: 0 8px 22px {rgba(deep,.42)};
}}
.light-panel .light-heading, .popup .popup-title,
.control-center .popup-title, .dashboard-panel .popup-title {{ color: {soft}; }}
.light-panel .light-sub, .popup .song-artist {{ color: {soft}; }}
.light-panel button, .popup button, .control-center button, .dashboard-panel button {{
  color: {fg};
  background-color: {rgba(accent,.28)};
  border: 1px solid {rgba(soft,.25)};
  border-radius: 13px;
}}
.light-panel button:hover, .popup button:hover,
.control-center button:hover, .dashboard-panel button:hover {{
  background-color: {rgba(soft,.32)};
  border-color: {soft};
}}
.light-panel scale trough, .popup scale trough {{
  background-color: {rgba(deep,.52)};
  border-radius: 9px;
}}
.light-panel scale highlight, .popup scale highlight {{
  background-color: {accent};
  border-radius: 9px;
}}
.light-panel scale slider, .popup scale slider {{
  background-color: {soft};
  border-radius: 100%;
}}
.light-panel calendar, .popup calendar {{ color: {fg}; }}
.light-panel calendar:selected, .popup calendar:selected {{
  background-color: {accent}; color: {fg};
}}
'''
(d/'_popup-palette.scss').write_text(css)
print('Popup palette:',accent,soft,deep,ink,fg)
