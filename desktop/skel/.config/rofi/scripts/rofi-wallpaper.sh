#!/usr/bin/env bash

light_dir="$HOME/.config/Light/wallpaper/Light"
dark_dir="$HOME/.config/Light/wallpaper/Dark"
theme_script="$HOME/.config/Light/Theme.sh"
light_flag="$HOME/.config/hypr/Light.txt"
dark_flag="$HOME/.config/hypr/Dark.txt"
thumbnail_dir="$HOME/.cache/LightOS/wallpaper-thumbnails/menu"
rofi_bin="$HOME/bin/rofi"
rofi_theme="$HOME/.config/rofi/themes/wallpaper.rasi"
mkdir -p "$thumbnail_dir"

mapfile -d '' wallpapers < <(
    find "$light_dir" "$dark_dir" -maxdepth 1 -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \
        -o -iname '*.mp4' -o -iname '*.webm' -o -iname '*.mkv' -o -iname '*.mov' \
        -o -iname '*.m4v' -o -iname '*.avi' -o -iname '*.mpg' -o -iname '*.mpeg' \
        -o -iname '*.3gp' -o -iname '*.gif' \) -print0 | sort -z
)
((${#wallpapers[@]})) || exit 0

selected_label=$(
    for file in "${wallpapers[@]}"; do
        if [[ "$file" == "$light_dir"/* ]]; then
            label="Light: ${file##*/}"
        else
            label="Dark: ${file##*/}"
        fi

        extension="${file##*.}"
        case "${extension,,}" in
            mp4|webm|mkv|mov|m4v|avi|mpg|mpeg|3gp|gif)
                thumbnail="$thumbnail_dir/${file##*/}.png"
                if [[ ! -s "$thumbnail" ]]; then
                    ffmpeg -loglevel error -y -ss 1 -i "$file" -frames:v 1 \
                        -vf 'scale=320:180:force_original_aspect_ratio=decrease,pad=320:180:(ow-iw)/2:(oh-ih)/2' \
                        "$thumbnail" >/dev/null 2>&1 || continue
                fi
                icon="$thumbnail"
                ;;
            *) icon="$file" ;;
        esac
        printf '%s\0icon\x1f%s\n' "$label" "$icon"
    done | "$rofi_bin" -x11 -dmenu -theme "$rofi_theme"
)
[[ -n "$selected_label" ]] || exit 0

selected_wallpaper=""
theme_type=""
for file in "${wallpapers[@]}"; do
    if [[ "$file" == "$light_dir"/* ]]; then
        label="Light: ${file##*/}"
    else
        label="Dark: ${file##*/}"
    fi
    if [[ "$label" == "$selected_label" ]]; then
        selected_wallpaper="$file"
        [[ "$file" == "$light_dir"/* ]] && theme_type="Light" || theme_type="Dark"
        break
    fi
done
[[ -n "$selected_wallpaper" ]] || exit 1

if [[ "$theme_type" == "Light" && ! -f "$light_flag" ]] || \
   [[ "$theme_type" == "Dark" && ! -f "$dark_flag" ]]; then
    bash "$theme_script"
fi

pkill -x mpvpaper 2>/dev/null || true
extension="${selected_wallpaper##*.}"
case "${extension,,}" in
    mp4|webm|mkv|mov|m4v|avi|mpg|mpeg|3gp|gif)
        mpvpaper -o 'no-audio no-border keepaspect=no hwdec=auto loop-file=inf' \
            '*' "$selected_wallpaper" >/dev/null 2>&1 &
        notification_icon="$thumbnail_dir/${selected_wallpaper##*/}.png"
        ;;
    *)
        awww img --transition-duration 2 --transition-type grow \
            --transition-step 45 --transition-fps 30 "$selected_wallpaper"
        notification_icon="$selected_wallpaper"
        ;;
esac

python3 "$HOME/.config/waybar/Scripts/wallpaper-colors.py" "$selected_wallpaper" >/dev/null 2>&1 || true
notify-send -i "$notification_icon" "LightOS" "Wallpaper changed ($theme_type)"
