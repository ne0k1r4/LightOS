#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Usage: $0 --title | --arturl | --artist | --length | --album | --source"
    exit 1
fi

get_metadata() {
    key=$1
    playerctl metadata --format "{{ $key }}" 2>/dev/null
}

get_source_info() {
    trackid=$(get_metadata "mpris:trackid")
    if [[ "$trackid" == *"firefox"* ]]; then
        echo -e "Firefox 󰈹"
    elif [[ "$trackid" == *"spotify"* ]]; then
        echo -e "Spotify "
    elif [[ "$trackid" == *"chromium"* ]]; then
        echo -e "Chrome "
    elif [[ "$trackid" == *"kew"* ]]; then
        echo -e "Kew "
    else
        echo ""
    fi
}

case "$1" in
--title)
    title=$(get_metadata "xesam:title")
    [ -z "$title" ] && echo "" || echo "${title:0:28}"
    ;;
--arturl)
    url=$(get_metadata "mpris:artUrl")
    if [ -z "$url" ]; then
        echo ""
    else
        [[ "$url" == file://* ]] && url=${url#file://}
        echo "$url"
    fi
    ;;
--artist)
    artist=$(get_metadata "xesam:artist")
    [ -z "$artist" ] && echo "" || echo "${artist:0:30}"
    ;;
--length)
    length=$(get_metadata "mpris:length")
    [ -z "$length" ] && echo "" || echo "$(echo "scale=2; $length / 1000000 / 60" | bc) m"
    ;;
--status)
    status=$(playerctl status 2>/dev/null)
    [[ $status == "Playing" ]] && echo "󰎆" || [[ $status == "Paused" ]] && echo "󱑽" || echo ""
    ;;
--album)
    album=$(playerctl metadata --format "{{ xesam:album }}" 2>/dev/null)
    if [[ -n $album ]]; then
        echo "$album"
    else
        status=$(playerctl status 2>/dev/null)
        [[ -n $status ]] && echo "Unknown Album" || echo ""
    fi
    ;;
--source)
    get_source_info
    ;;
*)
    echo "Invalid option: $1"
    exit 1
    ;;
esac
