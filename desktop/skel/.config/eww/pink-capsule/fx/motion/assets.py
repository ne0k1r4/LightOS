#!/usr/bin/env python3
import re, sys, math
from pathlib import Path
from html import escape
home=Path.home(); base=home/'.config/eww/pink-capsule/fx/motion'
source=home/'.config/waybar/wallpaper-colors.css'
css=source.read_text(errors='replace') if source.exists() else ''
def get(n,default):
 m=re.search(r'@define-color\s+'+re.escape(n)+r'\s+(#[0-9a-fA-F]{6})\s*;',css)
 return m.group(1) if m else default
accent=get('wallpaper_accent','#f15cc7'); soft=get('wallpaper_accent_soft','#ffb5ee'); deep=get('wallpaper_accent_deep','#a74baf')
def write(path,contents):
 path.write_text(contents,encoding='utf-8')
# Self-contained vector graphics; GTK SVG loader required.
for i in range(12):
 phase=math.sin(i*math.tau/12)
 size=1+0.09*phase
 opacity=0.66+0.34*(phase+1)/2
 svg=f'''<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 40 40"><defs><radialGradient id="g"><stop stop-color="{soft}" stop-opacity=".75"/><stop offset="1" stop-color="{accent}" stop-opacity="0"/></radialGradient></defs><circle cx="20" cy="20" r="19" fill="url(#g)"/><g transform="translate(20 20) scale({size:.4f}) translate(-20 -20)" opacity="{opacity:.3f}"><path d="M20 33 C14 28 6 22 6 15 C6 8 15 7 20 13 C25 7 34 8 34 15 C34 22 26 28 20 33Z" fill="{deep}" stroke="{soft}" stroke-width="1.8"/><path d="M20 29 C15 25 10 20 10 15 C10 11 16 10 20 16 C24 10 30 11 30 15 C30 20 25 25 20 29Z" fill="{accent}"/><path d="M11 15 Q13 11 17 14" stroke="white" stroke-width="3" stroke-linecap="round" fill="none"/></g></svg>'''
 write(base/f'heart-{i:02}.svg',svg)
# 15 frames: 0 transparent; 1..13 sweeping beam; 14 transparent.
for i in range(15):
 if i in (0,14):
  content=''
 else:
  t=(i-1)/12
  x=215+290*t
  opacity=math.sin(math.pi*min(1,max(0,t)))**0.4
  # White-hot arrow tip, colored trail, cyan underside.
  content=f'''<defs><linearGradient id="trail" x1="0" x2="1"><stop stop-color="{deep}" stop-opacity="0"/><stop offset=".5" stop-color="{accent}" stop-opacity=".28"/><stop offset="1" stop-color="{soft}" stop-opacity=".95"/></linearGradient></defs><g opacity="{opacity:.3f}"><rect x="{max(0,x-185):.1f}" y="15" width="185" height="8" rx="4" fill="url(#trail)"/><path d="M{x-16:.1f} 8 L{x+11:.1f} 19 L{x-16:.1f} 30 L{x-10:.1f} 19Z" fill="{accent}" stroke="{soft}" stroke-width="2"/><path d="M{x-9:.1f} 13 L{x+7:.1f} 19 L{x-9:.1f} 25Z" fill="white"/><rect x="{x-105:.1f}" y="28" width="95" height="2" rx="1" fill="#85ecff" opacity=".65"/></g>'''
 write(base/f'ray-{i:02}.svg',f'<svg xmlns="http://www.w3.org/2000/svg" width="700" height="42" viewBox="0 0 700 42">{content}</svg>')
print('Wallpaper colors:',accent,soft,deep)
