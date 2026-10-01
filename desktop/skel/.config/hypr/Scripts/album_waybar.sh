#!/bin/bash

setsid bash -c '
while true; do
    if ! pgrep -x "battery-bar" > /dev/null; then
        sleep 9
        continue
    fi

    players=$(playerctl -l 2>/dev/null)
    index=1

    for player in $players; do
        status=$(playerctl -p "$player" status 2>/dev/null)
        if [[ $status == "Playing" ]]; then
            if [[ $index -eq 1 ]]; then
                output="/tmp/cover_music.png"
            else
                output="/tmp/cover_music${index}.png"
            fi

            album_art=$(playerctl -p "$player" metadata mpris:artUrl 2>/dev/null)

            if [[ -z $album_art && "$player" == "mpv" ]]; then
                album_art="$HOME/.config/waybar/icons/audio-headphones.png"
                cp "$album_art" "$output"
                echo "$output"
                ((index++))
                continue
            fi

            if [[ -z $album_art ]]; then
                ((index++))
                continue
            fi

            if [[ -f "$album_art" ]]; then
                cp "$album_art" /tmp/cover_tmp.jpeg
            elif [[ "$album_art" =~ ^file:// ]]; then
                cp "${album_art#file://}" /tmp/cover_tmp.jpeg
            else
                curl -s "${album_art}" --output "/tmp/cover_tmp.jpeg"
            fi

            convert /tmp/cover_tmp.jpeg -resize 128x128^ -gravity center -extent 128x128 \
                \( +clone -threshold -1 -negate -fill white -draw "circle 64,64 64,0" \) \
                -alpha off -compose CopyOpacity -composite "$output"

            echo "$output"
            ((index++))
        fi
    done

    existing=$(ls /tmp/cover_music*.png 2>/dev/null | wc -l)
    if (( existing > index - 1 )); then
        for extra in $(seq $index $existing); do
            rm -f "/tmp/cover_music${extra}.png" 2>/dev/null
        done
    fi

    sleep 2
done
' >/dev/null 2>&1 &
