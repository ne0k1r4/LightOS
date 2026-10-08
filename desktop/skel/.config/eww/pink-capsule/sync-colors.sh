#!/usr/bin/env bash
set -e

D="$HOME/.config/eww/pink-capsule"
SOURCE="$HOME/.config/waybar/wallpaper-colors.css"
OUTPUT="$D/_dynamic.scss"

[ -f "$SOURCE" ] || exit 0

python3 - "$SOURCE" "$OUTPUT" <<'PY'
import re
import sys
from pathlib import Path

source = Path(sys.argv[1]).read_text()
output = Path(sys.argv[2])

def get(name, default):
    match = re.search(
        r'@define-color\s+' + re.escape(name) +
        r'\s+(#[0-9a-fA-F]{6})\s*;',
        source
    )
    return match.group(1) if match else default

def rgba(hex_color, alpha):
    r, g, b = (
        int(hex_color[i:i+2], 16)
        for i in (1, 3, 5)
    )
    return f"rgba({r}, {g}, {b}, {alpha})"

accent = get("wallpaper_accent", "#b881b8")
soft = get("wallpaper_accent_soft", "#f5d2ed")
text = get("wallpaper_text", "#ffffff")

css = f"""
.pill {{
    background-color: {rgba(accent, 0.88)};
    border-color: {rgba(soft, 0.65)};
}}

.pill:hover {{
    background-color: {rgba(accent, 0.95)};
}}

.battery, .clock {{
    color: {text};
}}
"""

# Avoid unnecessary writes and reloads
if not output.exists() or output.read_text() != css:
    output.write_text(css)
    print("Capsule colors updated:", accent, soft)
PY
