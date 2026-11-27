#!/usr/bin/env bash
# Exercise the Control Panel card-preference helper in an isolated config home.
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/src/usr/share/argvus/control-panel/sh/cards-config.sh"
PANEL_QML="${PANEL_QML:-$ROOT_DIR/src/usr/share/argvus/control-panel/config/quickshell/argvus-control-panel/PanelContent.qml}"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT
export ARGVUS_CONFIG_HOME="$TEMP_DIR/config"

# Hardware probes may finish later than the card preference read. They must
# filter only their dependent cards, never cover or block the whole panel.
cards_loading="$(sed -n '/property bool cardsStatusReady:/,/property var cardDefinitions:/p' "$PANEL_QML" \
  | sed -n '/cardsLoading:/p')"
[[ "$cards_loading" == *'!cardsStatusReady'* && "$cards_loading" != *'hardwareCapabilitiesReady'* ]]
capability_check="$(sed -n '/function cardCapabilityAvailable(id)/,/^    }/p' "$PANEL_QML")"
[[ "$capability_check" == *'if (!hardwareCapabilitiesReady) return true'* ]]
rebuild_cards="$(sed -n '/function rebuildCards()/,/^    }/p' "$PANEL_QML")"
[[ "$rebuild_cards" != *'if (!hardwareCapabilitiesReady)'* ]]

status() { bash "$SCRIPT" status; }

[[ "$(status | jq '.cards | length')" == '13' ]]
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

# The master switch recreates the panel only when it changes.
mkdir -p "$TEMP_DIR/bin"
cat > "$TEMP_DIR/bin/systemctl" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$SYSTEMCTL_LOG"
STUB
chmod +x "$TEMP_DIR/bin/systemctl"
export SYSTEMCTL_LOG="$TEMP_DIR/systemctl.log"
master() { PATH="$TEMP_DIR/bin:$PATH" bash "$SCRIPT" master set "$1" >/dev/null; tail -n 1 "$SYSTEMCTL_LOG"; }

[[ "$(master enabled)" == '--user start argvus-control-panel.service' ]]
[[ "$(master disabled)" == '--user stop argvus-control-panel.service' ]]
[[ "$(master disabled)" == '--user stop argvus-control-panel.service' ]]
[[ "$(master enabled)" == '--user restart argvus-control-panel.service' ]]
[[ "$(bash "$SCRIPT" master status)" == 'enabled' ]]
