#!/usr/bin/env python3
import re
from pathlib import Path

home = Path.home()
base = home / ".config/eww/pink-capsule"
palette = home / ".config/waybar/wallpaper-colors.css"
css = base / "eww.scss"

source = palette.read_text() if palette.exists() else ""

def color(name, default):
    match = re.search(
        r"@define-color\s+" + re.escape(name) +
        r"\s+(#[0-9a-fA-F]{6})\s*;",
        source
    )
    return match.group(1) if match else default

accent = color("wallpaper_accent", "#ff69ce")
soft = color("wallpaper_accent_soft", "#ffd1ef")
deep = color("wallpaper_accent_deep", "#aa408f")

def rgba(value, alpha):
    r, g, b = (
        int(value[i:i+2], 16)
        for i in (1, 3, 5)
    )
    return f"rgba({r},{g},{b},{alpha})"

start = "/* WALLPAPER_RAY_START */"
end = "/* WALLPAPER_RAY_END */"

block = f"""
{start}

.ray-left, .ray-right {{
    background-image: linear-gradient(
        to bottom,
        {rgba(soft, 0.08)},
        {rgba(accent, 0.52)}
    );
    border-bottom: 2px solid {accent};
    box-shadow:
        0 2px 6px {rgba(accent, 0.65)},
        0 4px 12px {rgba(deep, 0.35)};
}}

.outer-heart-img {{
    -gtk-icon-shadow: 0 0 7px {soft};
}}

{end}
"""

original = css.read_text()
original = re.sub(
    re.escape(start) + r".*?" + re.escape(end),
    "",
    original,
    flags=re.S
)

css.write_text(original + "\n" + block)

# Remove old inline ray styling, which overrides CSS.
yuck = base / "eww.yuck"
text = yuck.read_text()

pattern = (
    r'(\(box\s+:class\s+"extras ray-(?:left|right)")'
    r'\s+:style\s+"[^"]*"'
)

updated, count = re.subn(pattern, r'\1', text)

if count:
    yuck.write_text(updated)

print("Wallpaper ray colors updated:")
print("Accent:", accent)
print("Soft:", soft)
print("Deep:", deep)
print("Inline ray styles removed:", count)
