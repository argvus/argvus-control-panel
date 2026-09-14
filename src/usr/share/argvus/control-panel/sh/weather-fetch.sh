#!/usr/bin/env sh
# Fetch weather data for the control-panel card.
# wttr.in is preferred for compatibility; Open-Meteo is the keyless fallback.

set -eu

LOCATION="${1:-}"
TMP_DIR="${TMPDIR:-/tmp}/argvus-weather.$$"
mkdir -p "$TMP_DIR"
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

urlencode() {
  jq -nr --arg value "$1" '$value | @uri'
}

valid_wttr_response() {
  jq -e '(.current_condition | type == "array" and length > 0) and (.nearest_area | type == "array" and length > 0)' \
    "$1" >/dev/null 2>&1
}

fetch_wttr() {
  _url="https://wttr.in/"
  if [ -n "$LOCATION" ]; then
    _url="${_url}$(urlencode "$LOCATION")"
  fi
  _url="${_url}?format=j1"

  curl -4 -fsSL --connect-timeout 8 --max-time 12 "$_url" -o "$TMP_DIR/wttr.json" 2>/dev/null || return 1
  valid_wttr_response "$TMP_DIR/wttr.json" || return 1
  cat "$TMP_DIR/wttr.json"
}

geocode_location() {
  [ -n "$LOCATION" ] || return 1
  _query="$(urlencode "$LOCATION")"
  curl -4 -fsSL --connect-timeout 8 --max-time 12 \
    "https://geocoding-api.open-meteo.com/v1/search?name=${_query}&count=1&language=en&format=json" \
    -o "$TMP_DIR/geocode.json" 2>/dev/null || return 1
  jq -e '.results[0] | (.latitude and .longitude)' "$TMP_DIR/geocode.json" >/dev/null 2>&1 || return 1
  jq -r '.results[0] | [.latitude, .longitude, (.name // ""), (.country // "")] | @tsv' "$TMP_DIR/geocode.json"
}

locate_by_ip() {
  curl -4 -fsSL --connect-timeout 8 --max-time 12 https://ipinfo.io/json \
    -o "$TMP_DIR/ip.json" 2>/dev/null || return 1
  jq -e '.loc' "$TMP_DIR/ip.json" >/dev/null 2>&1 || return 1
  jq -r '[.loc | split(",")[]] + [(.city // ""), (.country // "")] | @tsv' "$TMP_DIR/ip.json"
}

fetch_open_meteo() {
  if [ -n "$LOCATION" ]; then
    _place="$(geocode_location)" || return 1
  else
    _place="$(locate_by_ip)" || return 1
  fi

  IFS='	' read -r _latitude _longitude _city _country <<EOF
$_place
EOF

  curl -4 -fsSL --connect-timeout 8 --max-time 12 \
    "https://api.open-meteo.com/v1/forecast?latitude=${_latitude}&longitude=${_longitude}&current=temperature_2m,relative_humidity_2m,apparent_temperature,wind_speed_10m,weather_code&timezone=auto" \
    -o "$TMP_DIR/forecast.json" 2>/dev/null || return 1

  jq -e '.current' "$TMP_DIR/forecast.json" >/dev/null 2>&1 || return 1
  jq --arg city "$_city" --arg country "$_country" '
    def description:
      if . == 0 then "Clear sky"
      elif . <= 3 then "Partly cloudy"
      elif . <= 48 then "Fog"
      elif . <= 57 then "Drizzle"
      elif . <= 67 then "Rain"
      elif . <= 77 then "Snow"
      elif . <= 82 then "Rain showers"
      elif . <= 86 then "Snow showers"
      elif . <= 99 then "Thunderstorm"
      else "Unknown"
      end;
    {
      current_condition: [{
        temp_C: (.current.temperature_2m | tostring),
        FeelsLikeC: (.current.apparent_temperature | tostring),
        humidity: (.current.relative_humidity_2m | tostring),
        windspeedKmph: ((.current.wind_speed_10m * 3.6) | round | tostring),
        weatherCode: (.current.weather_code | tostring),
        weatherDesc: [{value: (.current.weather_code | description)}]
      }],
      nearest_area: [{
        areaName: [{value: $city}],
        country: [{value: $country}]
      }]
    }
  ' "$TMP_DIR/forecast.json"
}

fetch_wttr || fetch_open_meteo
