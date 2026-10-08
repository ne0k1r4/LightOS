#!/usr/bin/env python3
import sys,time
from pathlib import Path
b=Path.home()/'.config/eww/pink-capsule/fx/motion'
mode=sys.argv[1] if len(sys.argv)>1 else 'heart'
if mode=='heart':
 i=int(time.monotonic()*12)%12
else:
 try:
  start=float((b/'start').read_text())
  age=time.monotonic()-start
  i=min(13,max(1,int(age/.035)+1)) if 0<=age<.46 else 14
 except (OSError,ValueError): i=14
print((b/f'{mode}-{i:02}.svg').as_uri() if mode=='ray' else str(b/f'{mode}-{i:02}.svg'))
