#!/usr/bin/env python3
import sys, time
from pathlib import Path
base = Path.home()/'.config/eww/pink-capsule/fx'
mode = sys.argv[1] if len(sys.argv)>1 else 'heart'
if mode == 'heart':
    index = int(time.monotonic()*10) % 12
    print(base/'assets'/f'heart-{index:02}.png')
else:
    try:
        stamp = float((base/'ray-start').read_text().strip())
        age = time.monotonic()-stamp
        index = min(11, max(0, int(age/.045))) if 0 <= age < .495 else 11
    except (OSError, ValueError):
        index = 11
    print(base/'assets'/f'ray-{index:02}.png')
