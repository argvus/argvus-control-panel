#!/usr/bin/env sh
# shellcheck shell=sh
#
# toggle-sidebar.sh — toggles the argvus-control-panel on/off.
#
# The sidebar runs as a long-lived quickshell process (qs -c argvus-control-panel).
# The bare `qs ... ipc call sidebar toggle` only works while that process is
# already running; on a fresh user/session it may not be up yet, so the button
# and SUPER+, would silently do nothing. This helper starts the sidebar if it
# is not running, otherwise it toggles it via IPC.

set -eu

ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
# shellcheck disable=SC1091
. "$ARGVUS_BOOTSTRAP"

BARS_SHELL="$(paths_config taskbar/quickshell/shell.qml)"

if qs -p "$BARS_SHELL" ipc call sidebar toggle >/dev/null 2>&1; then
  exit 0
fi

if command -v systemctl >/dev/null 2>&1; then
  if systemctl --user start argvus-taskbar.service >/dev/null 2>&1; then
    sleep 0.3
    qs -p "$BARS_SHELL" ipc call sidebar toggle >/dev/null 2>&1 || true
  fi
fi

exit 0
