import subprocess
import time
import json
import syncedlyrics

PLAYERCTL_PATH = "/usr/bin/playerctl"
REFRESH_INTERVAL = 1
NO_LYRICS_TEXT = "♪ no lyrics found"
IDLE_TEXT = "♪ nothing playing"

lyrics_cache = {}  # song_key -> list of (timestamp, line)
current_song_key = None

def get_active_player():
    result = subprocess.run([PLAYERCTL_PATH, '-l'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    players = result.stdout.decode('utf-8').strip().split('\n')
    players = [p for p in players if p and "firefox" not in p.lower() and "chromium" not in p.lower()]
    if "kew" in players:
        return "kew"
    return players[0] if players else None

def get_song_info(player):
    try:
        title = subprocess.run([PLAYERCTL_PATH, '-p', player, 'metadata', 'title'], stdout=subprocess.PIPE).stdout.decode().strip()
        artist = subprocess.run([PLAYERCTL_PATH, '-p', player, 'metadata', 'artist'], stdout=subprocess.PIPE).stdout.decode().strip()
        if not title:
            return None, None
        return title, artist
    except Exception:
        return None, None

def get_position(player):
    try:
        pos = subprocess.run([PLAYERCTL_PATH, '-p', player, 'position'], stdout=subprocess.PIPE).stdout.decode().strip()
        return float(pos)
    except Exception:
        return 0.0

def parse_lrc(lrc_text):
    # turns raw lrc string into a sorted list of (seconds, line)
    lines = []
    for raw_line in lrc_text.split('\n'):
        if not raw_line.startswith('['):
            continue
        try:
            timestamp, text = raw_line.split(']', 1)
            minutes, seconds = timestamp[1:].split(':')
            total_seconds = int(minutes) * 60 + float(seconds)
            if text.strip():
                lines.append((total_seconds, text.strip()))
        except Exception:
            continue
    lines.sort(key=lambda x: x[0])
    return lines

def fetch_lyrics(title, artist):
    try:
        search_term = f"{title} {artist}" if artist else title
        lrc = syncedlyrics.search(search_term, synced_only=True)
        return parse_lrc(lrc) if lrc else []
    except Exception as e:
        print(f"lyrics fetch failed: {e}")
        return []

def get_current_line(lines, position):
    current = ""
    for timestamp, text in lines:
        if timestamp <= position:
            current = text
        else:
            break
    return current

if __name__ == "__main__":
    while True:
        output = {}
        try:
            player = get_active_player()
            if not player:
                output['text'] = IDLE_TEXT
                current_song_key = None
            else:
                title, artist = get_song_info(player)
                if not title:
                    output['text'] = IDLE_TEXT
                    current_song_key = None
                else:
                    song_key = f"{title}|{artist}"
                    if song_key != current_song_key:
                        current_song_key = song_key
                        lyrics_cache[song_key] = fetch_lyrics(title, artist)

                    lines = lyrics_cache.get(song_key, [])
                    if not lines:
                        output['text'] = NO_LYRICS_TEXT
                    else:
                        position = get_position(player)
                        line = get_current_line(lines, position)
                        output['text'] = f"♪ {line}" if line else "♪ ..."
                        upcoming = [l[1] for l in lines if l[0] > position][:2]
                        output['tooltip'] = "\n".join(upcoming) if upcoming else ""
        except Exception as e:
            output['text'] = f"lyrics error: {e}"

        print(json.dumps(output), flush=True)
        time.sleep(REFRESH_INTERVAL)
