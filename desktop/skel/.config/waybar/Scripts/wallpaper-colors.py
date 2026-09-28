#!/usr/bin/env python3
"""Generate a small GTK palette from an image or video wallpaper."""

from __future__ import annotations

import colorsys
import io
import subprocess
import sys
from pathlib import Path

from PIL import Image


WAYBAR = Path.home() / ".config/waybar"
VIDEO_EXTENSIONS = {".3gp", ".avi", ".gif", ".m4v", ".mkv", ".mov", ".mp4", ".mpeg", ".mpg", ".webm"}


def load_image(path: Path) -> Image.Image:
    if path.suffix.lower() in VIDEO_EXTENSIONS:
        result = subprocess.run(
            ["ffmpeg", "-loglevel", "error", "-ss", "1", "-i", str(path),
             "-frames:v", "1", "-f", "image2pipe", "-vcodec", "png", "pipe:1"],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        return Image.open(io.BytesIO(result.stdout)).convert("RGB")
    return Image.open(path).convert("RGB")


def hex_color(rgb: tuple[int, int, int]) -> str:
    return "#%02x%02x%02x" % rgb


def mix(a: tuple[int, int, int], b: tuple[int, int, int], amount: float) -> tuple[int, int, int]:
    return tuple(round(x * (1 - amount) + y * amount) for x, y in zip(a, b))


def palette(image: Image.Image) -> dict[str, str]:
    image.thumbnail((128, 128))
    quantized = image.quantize(colors=16, method=Image.Quantize.MEDIANCUT)
    counts = quantized.getcolors(128 * 128) or []
    colors = quantized.getpalette() or []
    candidates: list[tuple[float, tuple[int, int, int], float, float]] = []
    for count, index in counts:
        rgb = tuple(colors[index * 3:index * 3 + 3])
        hue, saturation, value = colorsys.rgb_to_hsv(*(component / 255 for component in rgb))
        candidates.append((count * (0.35 + saturation), rgb, hue, saturation))
    candidates.sort(reverse=True)

    accent = candidates[0][1] if candidates else (110, 119, 189)
    hue = candidates[0][2] if candidates else 0.65
    secondary = next(
        (item[1] for item in candidates[1:] if item[3] > 0.12 and min(abs(item[2] - hue), 1 - abs(item[2] - hue)) > 0.08),
        None,
    )
    if secondary is None:
        secondary = colorsys.hsv_to_rgb((hue + 0.08) % 1, 0.48, 0.94)
        secondary = tuple(round(component * 255) for component in secondary)

    soft = mix(accent, secondary, 0.38)
    soft = mix(soft, (255, 255, 255), 0.66)
    pale = mix(soft, (255, 255, 255), 0.50)
    deep = mix(accent, (12, 15, 28), 0.46)
    luminance = sum(weight * channel for weight, channel in zip((0.2126, 0.7152, 0.0722), accent)) / 255
    text = (27, 26, 38) if luminance > 0.58 else (255, 255, 255)

    return {
        "wallpaper_accent": hex_color(accent),
        "wallpaper_accent_soft": hex_color(soft),
        "wallpaper_accent_pale": hex_color(pale),
        "wallpaper_accent_deep": hex_color(deep),
        "wallpaper_ink": "#1e1e2e",
        "wallpaper_text": hex_color(text),
    }


def main() -> int:
    if len(sys.argv) != 2:
        print(f"Usage: {Path(sys.argv[0]).name} WALLPAPER", file=sys.stderr)
        return 2

    wallpaper = Path(sys.argv[1]).expanduser()
    try:
        colors = palette(load_image(wallpaper))
    except Exception as error:
        print(f"Could not create Waybar colors from {wallpaper}: {error}", file=sys.stderr)
        return 1

    css = "/* Generated from the active wallpaper. */\n" + "".join(
        f"@define-color {name} {value};\n" for name, value in colors.items()
    )
    target = WAYBAR / "wallpaper-colors.css"
    temporary = target.with_suffix(".css.tmp")
    temporary.write_text(css, encoding="utf-8")
    temporary.replace(target)

    subprocess.Popen(
        [str(WAYBAR / "Scripts" / "reload-waybar-colors.sh")],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
