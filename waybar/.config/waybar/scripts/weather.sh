#!/usr/bin/env bash
# Waybar weather module: auto-detects location (ip-api) and fetches the most
# precise Celsius temperature available (Open-Meteo, 1-decimal). No jq needed.
set -u

cache="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-weather.json"

emit() { printf '%s\n' "$1"; }

# JSON-escape a string (quotes, backslashes, newlines).
jesc() {
    local s=$1
    s=${s//\\/\\\\}
    s=${s//\"/\\\"}
    s=${s//$'\n'/\\n}
    printf '%s' "$s"
}

# --- location ---------------------------------------------------------------
loc=$(curl -sf --max-time 10 "http://ip-api.com/csv/?fields=city,lat,lon" 2>/dev/null)
city=$(printf '%s' "$loc" | cut -d, -f1)
lat=$(printf '%s'  "$loc" | cut -d, -f2)
lon=$(printf '%s'  "$loc" | cut -d, -f3)

# --- weather ----------------------------------------------------------------
if [ -n "$lat" ] && [ -n "$lon" ]; then
    data=$(curl -sf --max-time 10 \
        "https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,apparent_temperature,relative_humidity_2m,weather_code" 2>/dev/null)
fi

temp=$(printf '%s' "${data:-}" | grep -oP '"temperature_2m":\K[-0-9.]+')
feels=$(printf '%s' "${data:-}" | grep -oP '"apparent_temperature":\K[-0-9.]+')
hum=$(printf '%s' "${data:-}" | grep -oP '"relative_humidity_2m":\K[-0-9]+')
code=$(printf '%s' "${data:-}" | grep -oP '"weather_code":\K[0-9]+')

# Network/parse failed: reuse last good reading if we have one.
if [ -z "$temp" ]; then
    if [ -f "$cache" ]; then cat "$cache"; else emit '{"text":"󰅖 weather","tooltip":"Weather unavailable","class":"weather-error"}'; fi
    exit 0
fi

# --- WMO weather_code -> icon + description ---------------------------------
case "${code:-}" in
    0)            icon="" ; desc="Clear sky" ;;
    1)            icon="" ; desc="Mainly clear" ;;
    2)            icon="" ; desc="Partly cloudy" ;;
    3)            icon="" ; desc="Overcast" ;;
    45|48)        icon="" ; desc="Fog" ;;
    51|53|55)     icon="" ; desc="Drizzle" ;;
    56|57)        icon="" ; desc="Freezing drizzle" ;;
    61|63|65)     icon="" ; desc="Rain" ;;
    66|67)        icon="" ; desc="Freezing rain" ;;
    71|73|75|77)  icon="" ; desc="Snow" ;;
    80|81|82)     icon="" ; desc="Rain showers" ;;
    85|86)        icon="" ; desc="Snow showers" ;;
    95)           icon="" ; desc="Thunderstorm" ;;
    96|99)        icon="" ; desc="Thunderstorm w/ hail" ;;
    *)            icon="" ; desc="Weather" ;;
esac

text="${icon} ${temp}°C"

tip="${city:-Current location} — ${desc}"
[ -n "$feels" ] && tip="${tip}"$'\n'"Feels like ${feels}°C"
[ -n "$hum" ]   && tip="${tip}"$'\n'"Humidity ${hum}%"

out=$(printf '{"text":"%s","tooltip":"%s","class":"weather"}' "$(jesc "$text")" "$(jesc "$tip")")
mkdir -p "$(dirname "$cache")"
printf '%s\n' "$out" > "$cache"
emit "$out"
