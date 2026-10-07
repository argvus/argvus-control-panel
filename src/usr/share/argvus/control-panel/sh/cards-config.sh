#!/usr/bin/env bash
# Manage the persistent visibility and order of Control Panel cards.
#
# Package defaults remain in this file. User changes are stored separately so
# package upgrades can add cards without overwriting personal preferences.
set -euo pipefail

CONFIG_HOME="${ARGVUS_CONFIG_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}}"
CONFIG_FILE="$CONFIG_HOME/argvus/data/control-panel/cards.json"
MASTER_FILE="$CONFIG_HOME/argvus/data/state/control-panel"
CARD_IDS=(
  user notifications calendar weather volume brightness network bluetooth
  system appearance session display spaces-borders-position power
)

usage() {
  printf 'usage: %s status | master status|set enabled|disabled | set <card> enabled|disabled | move <card> <index>\n' "${0##*/}" >&2
  exit 64
}

card_is_known() {
  local card="$1"
  local known
  for known in "${CARD_IDS[@]}"; do
    [[ "$known" == "$card" ]] && return 0
  done
  return 1
}

known_cards_json() {
  printf '%s\n' "${CARD_IDS[@]}" | jq -R . | jq -cs .
}

normalized_state() {
  local raw='{}'
  local known
  known="$(known_cards_json)"
  if [[ -f "$CONFIG_FILE" ]] && jq -e . "$CONFIG_FILE" >/dev/null 2>&1; then
    raw="$(<"$CONFIG_FILE")"
  fi

  jq -cn --argjson raw "$raw" --argjson known "$known" '
    def known_id: . as $id | $known | index($id) != null;
    def unique_known:
      reduce .[] as $id ([]; if ($id | known_id) and (index($id) | not) then . + [$id] else . end);
    ($raw.disabled // [] | if type == "array" then . else [] end | map(select(type == "string")) | unique_known) as $disabled |
    ($raw.order // [] | if type == "array" then . else [] end | map(select(type == "string")) | unique_known) as $saved_order |
    ($saved_order + ($known | map(select(. as $id | $saved_order | index($id) | not)))) as $order |
    { disabled: $disabled, order: $order }
  '
}

write_state() {
  local state="$1"
  local directory temporary
  directory="$(dirname -- "$CONFIG_FILE")"
  mkdir -p "$directory"
  temporary="$directory/.cards.json.$$"
  printf '%s\n' "$state" > "$temporary"
  mv -f "$temporary" "$CONFIG_FILE"
}

case "${1:-}" in
  master)
    [[ "$#" -ge 2 ]] || usage
    case "$2" in
      status)
        if [[ -r "$MASTER_FILE" ]] && [[ "$(sed -n '1p' "$MASTER_FILE")" == disabled ]]; then
          printf '%s\n' disabled
        else
          printf '%s\n' enabled
        fi
        ;;
      set)
        [[ "$#" -eq 3 ]] || usage
        case "$3" in enabled|disabled) ;; *) usage ;; esac
        mkdir -p "$(dirname -- "$MASTER_FILE")"
        printf '%s\n' "$3" > "$MASTER_FILE"
        if command -v systemctl >/dev/null 2>&1; then
          if [[ "$3" == enabled ]]; then
            systemctl --user restart argvus-control-panel.service >/dev/null 2>&1 || true
          else
            systemctl --user stop argvus-control-panel.service >/dev/null 2>&1 || true
          fi
        fi
        printf '%s\n' "$3"
        ;;
      *) usage ;;
    esac
    ;;
    status)
    [[ $# -eq 1 ]] || usage
    normalized_state | jq '
      . as $state |
      { cards: [ $state.order[] | . as $card_id |
          { id: $card_id, enabled: ($state.disabled | index($card_id) == null) } ] }
    '
    ;;
  set)
    [[ $# -eq 3 ]] || usage
    card_is_known "$2" || { printf 'unknown Control Panel card: %s\n' "$2" >&2; exit 65; }
    case "$3" in enabled|disabled) ;; *) usage ;; esac
    state="$(normalized_state | jq --arg card "$2" --arg value "$3" '
      if $value == "enabled" then .disabled -= [$card]
      else .disabled = ((.disabled + [$card]) | unique)
      end
    ')"
    write_state "$state"
    ;;
  move)
    [[ $# -eq 3 ]] || usage
    card_is_known "$2" || { printf 'unknown Control Panel card: %s\n' "$2" >&2; exit 65; }
    [[ "$3" =~ ^[0-9]+$ ]] || { printf 'invalid Control Panel card index: %s\n' "$3" >&2; exit 65; }
    [[ "$3" -lt "${#CARD_IDS[@]}" ]] || { printf 'invalid Control Panel card index: %s\n' "$3" >&2; exit 65; }
    state="$(normalized_state | jq --arg card "$2" --argjson index "$3" '
      .order as $order |
      ($order | map(select(. != $card))) as $without |
      .order = ($without[0:$index] + [$card] + $without[$index:])
    ')"
    write_state "$state"
    ;;
  *) usage ;;
esac
