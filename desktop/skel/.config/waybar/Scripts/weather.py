import requests
import json

GLYPHS = {
    "Sunny": "",
    "Clear": "",
    "Partly cloudy": "",
    "Cloudy": "",
    "Overcast": "",
    "Mist": "",
    "Fog": "",
    "Patchy rain possible": "",
    "Light rain": "",
    "Moderate rain": "",
    "Heavy rain": "",
    "Snow": "",
    "Thundery outbreaks possible": "",
}
DEFAULT_GLYPH = ""

def get_weather():
    try:
        # empty location = wttr.in figures it out from your ip, change to
        # "https://wttr.in/YourCity?format=j1" if you want it locked in
        res = requests.get("https://wttr.in/?format=j1", timeout=5)
        data = res.json()
        current = data['current_condition'][0]
        temp = current['temp_C']
        desc = current['weatherDesc'][0]['value']
        glyph = GLYPHS.get(desc, DEFAULT_GLYPH)
        return {
            "text": f"{glyph} {temp}°C",
            "tooltip": f"{desc}, feels like {current['FeelsLikeC']}°C\nhumidity {current['humidity']}%"
        }
    except Exception as e:
        return {"text": " ?", "tooltip": f"weather fetch failed: {e}"}

if __name__ == "__main__":
    print(json.dumps(get_weather()))
