#!/bin/bash
# rollback to waybar as default bar

echo "Rolling back to Waybar as default desktop bar..."

# stop capsule
pkill -f "eww.*pink-capsule" 2>/dev/null
eww -c ~/.config/eww/pink-capsule close-all 2>/dev/null

# update auto_start.lua
if [ -f ~/.config/hypr/auto_start.lua ]; then
    sed -i 's|hl.exec_cmd("~/.config/eww/pink-capsule/start.sh")|-- hl.exec_cmd("~/.config/eww/pink-capsule/start.sh")|' ~/.config/hypr/auto_start.lua
    sed -i 's|-- hl.exec_cmd("waybar")|hl.exec_cmd("waybar")|' ~/.config/hypr/auto_start.lua
    echo "✓ Updated auto_start.lua"
fi

# start waybar
waybar &
echo "✓ Waybar launched"

echo ""
echo "Rollback complete. Waybar is now the default bar."
echo "To revert back to capsule, run: ~/bin/toggle-bar.sh"
