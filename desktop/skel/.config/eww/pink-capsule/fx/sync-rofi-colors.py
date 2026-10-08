#!/usr/bin/env python3
from pathlib import Path
import re

home = Path.home()
source = home / ".config/waybar/wallpaper-colors.css"
theme = home / ".config/rofi/themes/lightos-capsule.rasi"

if not source.exists():
    raise SystemExit("Wallpaper palette not found")

data = source.read_text()

def get(name, default):
    match = re.search(
        r"@define-color\s+" + re.escape(name) +
        r"\s+(#[0-9a-fA-F]{6})\s*;",
        data
    )
    return match.group(1) if match else default

accent = get("wallpaper_accent", "#b881b8")
soft = get("wallpaper_accent_soft", "#e6c5df")
ink = get("wallpaper_ink", "#1e1e2e")
text = get("wallpaper_text", "#ffffff")

content = f'''
* {{
    background: {ink}ee;
    foreground: {text};
    accent: {accent};
    border-color: {soft};
}}

window {{
    location: north;
    anchor: north;
    x-offset: 0px;
    y-offset: 58px;
    width: 310px;
    border: 1px;
    border-radius: 18px;
    background-color: @background;
}}

mainbox {{
    padding: 12px;
    spacing: 8px;
    background-color: transparent;
}}

listview {{
    lines: 6;
    spacing: 5px;
    background-color: transparent;
}}

element {{
    padding: 8px;
    border-radius: 10px;
}}

element selected {{
    background-color: @accent;
    text-color: {text};
}}
'''

if not theme.exists() or theme.read_text() != content:
    theme.write_text(content)
    print("Rofi theme updated:", accent)
