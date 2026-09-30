#!/usr/bin/env sh
# Configure the location used by the Quickshell weather card.
# Usage: weather-location.sh [status|--auto|LOCATION]
# shellcheck disable=SC1091

set -eu

ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"

STATE_DIR="${ARGVUS_CONFIG_HOME}/argvus/data"
LOCATION_FILE="${STATE_DIR}/.weather-location"

read_location() {
  if [ -f "$LOCATION_FILE" ]; then
    sed -n '1p' "$LOCATION_FILE"
  fi
}

select_location() {
  _current="$(read_location)"
  _auto="$(argvus_tr control-panel weather.location.auto)"
  _prompt="$(argvus_tr control-panel weather.location.title)"
  _message="$(argvus_tr control-panel weather.location.prompt)"

  if [ -n "$_current" ]; then
    _options=$(printf '%s\n%s\n' "$_auto" "$_current")
  else
    _options=$(printf '%s\n' "$_auto")
  fi

  if ! _selection=$(printf '%s' "$_options" | rofi -config "$(paths_config launcher/config/config.rasi)" -dmenu -i -p "$_prompt" -mesg "$_message"); then
    return 1
  fi

  case "$_selection" in
    "$_auto") printf '\n' ;;
    *) printf '%s\n' "$_selection" ;;
  esac
}

case "${1:-}" in
  status)
    read_location
    exit 0
    ;;
  --auto)
    REQUESTED=""
    ;;
  '')
    REQUESTED="$(select_location)" || exit 0
    ;;
  *)
    REQUESTED="$1"
    ;;
esac

LOCATION=$(printf '%s' "$REQUESTED" | tr -d '\r\n' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
if [ "${#LOCATION}" -gt 120 ]; then
  argvus_tr control-panel weather.location.too_long >&2
  exit 1
fi

mkdir -p "$STATE_DIR"
printf '%s\n' "$LOCATION" > "$LOCATION_FILE"

if [ -n "$LOCATION" ]; then
  MESSAGE="$LOCATION"
else
  MESSAGE="Automatic (IP)"
fi
SUMMARY="$(argvus_tr control-panel weather.notification.title)"
[ -n "$LOCATION" ] || MESSAGE="$(argvus_tr control-panel weather.notification.auto)"

notify-send "$SUMMARY" "$MESSAGE" 2>/dev/null || true
printf '%s\n' "$LOCATION"
