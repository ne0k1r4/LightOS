#!/usr/bin/env python3
"""Waybar MPRIS title and album-art helper for LightOS."""

import json
import shutil
import subprocess
import sys
from pathlib import Path
from urllib.parse import unquote, urlparse
from urllib.request import Request, urlopen

PLAYERCTL = "/usr/bin/playerctl"
FALLBACK_ART = "/home/LIGHT/.config/Light/assets/disc.png"
CACHE_BASE = Path("/tmp/lightos-waybar-cover")
STATE_FILE = Path("/tmp/lightos-waybar-cover.url")
COVER_OUTPUT = Path("/tmp/cover_waybar.png")


def run_playerctl(*args):
    try:
        result = subprocess.run(
            [PLAYERCTL, *args], capture_output=True, text=True, timeout=2, check=False
        )
    except (OSError, subprocess.TimeoutExpired):
        return ""
    return result.stdout.strip() if result.returncode == 0 else ""


def current_player():
    players = [p for p in run_playerctl("-l").splitlines() if p]
    paused = None
    for player in players:
        status = run_playerctl("-p", player, "status").lower()
        if status == "playing":
            return player, status
        if status == "paused" and paused is None:
            paused = (player, status)
    return paused or (None, "stopped")


def metadata(player, key):
    return run_playerctl("-p", player, "metadata", key) if player else ""


def track_info():
    player, status = current_player()
    title = metadata(player, "xesam:title")
    artist = metadata(player, "xesam:artist")
    art_url = metadata(player, "mpris:artUrl")
    clean = lambda value: " ".join(value.replace("\n", " ").split())
    title, artist = clean(title), clean(artist)
    label = title or ("Nothing playing" if not player else "Unknown track")
    tooltip = " — ".join(value for value in (title, artist) if value)
    if not tooltip:
        tooltip = label
    return player, status, label, artist, tooltip, art_url


def art_path(url):
    if not url:
        return FALLBACK_ART
    parsed = urlparse(url)
    if parsed.scheme == "file":
        path = Path(unquote(parsed.path))
        return str(path) if path.is_file() else FALLBACK_ART
    if not parsed.scheme:
        path = Path(url)
        return str(path) if path.is_file() else FALLBACK_ART
    if parsed.scheme not in ("http", "https"):
        return FALLBACK_ART

    suffix = Path(parsed.path).suffix.lower()
    if suffix not in (".png", ".jpg", ".jpeg", ".webp", ".gif"):
        suffix = ".img"
    cached = Path(f"{CACHE_BASE}{suffix}")
    try:
        if STATE_FILE.read_text(encoding="utf-8") == url and cached.is_file():
            return str(cached)
    except OSError:
        pass

    try:
        request = Request(url, headers={"User-Agent": "LightOS-Waybar/1.0"})
        with urlopen(request, timeout=4) as response:
            content = response.read(15 * 1024 * 1024 + 1)
        if not content or len(content) > 15 * 1024 * 1024:
            return FALLBACK_ART
        cached.write_bytes(content)
        STATE_FILE.write_text(url, encoding="utf-8")
        return str(cached)
    except Exception:
        return FALLBACK_ART


def refresh_cover(url):
    cache_key = url or "no-art"
    try:
        if STATE_FILE.read_text(encoding="utf-8") == cache_key and COVER_OUTPUT.is_file():
            return str(COVER_OUTPUT)
    except OSError:
        pass

    source = art_path(url)
    try:
        converted = subprocess.run(
            ["magick", source, "-thumbnail", "128x128^", "-gravity", "center",
             "-extent", "128x128", str(COVER_OUTPUT)],
            capture_output=True, timeout=5, check=False,
        )
        if converted.returncode != 0:
            shutil.copyfile(source, COVER_OUTPUT)
    except (OSError, subprocess.TimeoutExpired):
        shutil.copyfile(source, COVER_OUTPUT)
    try:
        STATE_FILE.write_text(cache_key, encoding="utf-8")
    except OSError:
        pass
    return str(COVER_OUTPUT)


def main():
    player, status, title, artist, tooltip, art_url = track_info()
    if len(sys.argv) > 1 and sys.argv[1] == "--image":
        print(refresh_cover(art_url))
        print(tooltip)
        return

    text = f"♫  {title}" + (f"  —  {artist}" if artist else "")
    print(json.dumps({"text": text, "tooltip": tooltip, "class": status or "stopped"}))


if __name__ == "__main__":
    main()
