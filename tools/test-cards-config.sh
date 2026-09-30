#!/usr/bin/env bash
# Exercise the Control Panel card-preference helper in an isolated config home.
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/src/usr/share/argvus/control-panel/sh/cards-config.sh"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT
export ARGVUS_CONFIG_HOME="$TEMP_DIR/config"

status() { bash "$SCRIPT" status; }

[[ "$(status | jq '.cards | length')" == '14' ]]
[[ "$(status | jq -r '.cards[0].id')" == 'user' ]]
[[ "$(status | jq -r '.cards[] | select(.id == "user").enabled')" == 'true' ]]
[[ "$(status | jq -r '.cards[] | select(.id == "weather").enabled')" == 'true' ]]

bash "$SCRIPT" set weather disabled
[[ "$(status | jq -r '.cards[] | select(.id == "weather").enabled')" == 'false' ]]

bash "$SCRIPT" move power 0
[[ "$(status | jq -r '.cards[0].id')" == 'power' ]]

mkdir -p "$ARGVUS_CONFIG_HOME/argvus/data/control-panel"
printf '{ invalid json' > "$ARGVUS_CONFIG_HOME/argvus/data/control-panel/cards.json"
[[ "$(status | jq -r '.cards[0].id')" == 'user' ]]

if bash "$SCRIPT" set about disabled >/dev/null 2>&1; then
  printf 'About must not be configurable\n' >&2
  exit 1
fi
