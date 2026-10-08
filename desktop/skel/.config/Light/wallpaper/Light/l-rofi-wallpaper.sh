#!/usr/bin/env bash

# LIGHTOS_CAPSULE_ROFI_FIX
rofi() {
    command rofi "$@"       -theme "$HOME/.config/rofi/themes/lightos-capsule.rasi"       -theme-str 'window { location: north; anchor: north; x-offset: 0px; y-offset: 58px; width: 310px; }'
}

wall_dir="$HOME/.config/Light/wallpaper/Light"
thumbnail_dir="$HOME/.cache/LightOS/wallpaper-thumbnails/Light"
rofi_bin="$HOME/bin/rofi"
rofi_theme="$HOME/.config/rofi/themes/wallpaper.rasi"
mkdir -p "$thumbnail_dir"

selected_name=$(
    find "$wall_dir" -maxdepth 1 -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \
        -o -iname '*.mp4' -o -iname '*.webm' -o -iname '*.mkv' -o -iname '*.mov' \
        -o -iname '*.m4v' -o -iname '*.avi' -o -iname '*.mpg' -o -iname '*.mpeg' \
        -o -iname '*.3gp' -o -iname '*.gif' \) -print0 |
    sort -z | while IFS= read -r -d '' file; do
        name="${file##*/}"
        case "${file##*.}" in
            mp4|MP4|webm|WEBM|mkv|MKV|mov|MOV|m4v|M4V|avi|AVI|mpg|MPG|mpeg|MPEG|3gp|3GP|gif|GIF)
                thumbnail="$thumbnail_dir/$name.png"
                if [[ ! -s "$thumbnail" ]]; then
                    ffmpeg -loglevel error -y -ss 1 -i "$file" -frames:v 1 \
                        -vf 'scale=320:180:force_original_aspect_ratio=decrease,pad=320:180:(ow-iw)/2:(oh-ih)/2' \
                        "$thumbnail" >/dev/null 2>&1 || continue
                fi
                icon="$thumbnail"
                ;;
            *) icon="$file" ;;
        esac
        printf '%s\0icon\x1f%s\n' "$name" "$icon"
    done | "$rofi_bin" -x11 -dmenu -theme "$rofi_theme"
)

[[ -n "$selected_name" ]] || exit 0
selected_wallpaper="$wall_dir/$selected_name"
[[ -f "$selected_wallpaper" ]] || exit 1

case "${selected_wallpaper##*.}" in
    mp4|MP4|webm|WEBM|mkv|MKV|mov|MOV|m4v|M4V|avi|AVI|mpg|MPG|mpeg|MPEG|3gp|3GP|gif|GIF)
        pkill -x mpvpaper 2>/dev/null || true
        mpvpaper -o 'no-audio no-border keepaspect=no hwdec=auto loop-file=inf' \
            '*' "$selected_wallpaper" >/dev/null 2>&1 &
        notification_icon="$thumbnail_dir/$selected_name.png"
        ;;
    *)
        pkill -x mpvpaper 2>/dev/null || true
        awww img --transition-duration 2 --transition-type grow \
            --transition-step 45 --transition-fps 30 "$selected_wallpaper"
        notification_icon="$selected_wallpaper"
        ;;
esac

python3 "$HOME/.config/waybar/Scripts/wallpaper-colors.py" "$selected_wallpaper" >/dev/null 2>&1 || true
notify-send -i "$notification_icon" "LightOS" "Wallpaper was changed"
