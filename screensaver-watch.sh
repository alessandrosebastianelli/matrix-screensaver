#!/usr/bin/env bash
# screensaver-watch.sh
# Watches an activity timestamp file (touched by a shell prompt hook) and
# launches the Matrix screensaver after $MATRIX_IDLE_SECONDS of no activity.
# Works in a plain terminal, over SSH, and in iTerm2. Does not rely on tty
# atime, which is unreliable on macOS/APFS.

MATRIX_IDLE_SECONDS="${MATRIX_IDLE_SECONDS:-120}"
MATRIX_BIN="${MATRIX_BIN:-$HOME/.local/bin/matrix.py}"
POLL_INTERVAL=5

tty_dev="$(tty 2>/dev/null)"
[ -z "$tty_dev" ] || [ "$tty_dev" = "not a tty" ] && exit 0

ACTIVITY_FILE="${MATRIX_ACTIVITY_FILE:?MATRIX_ACTIVITY_FILE not set}"
touch "$ACTIVITY_FILE" 2>/dev/null || exit 0

get_mtime() {
  if stat -f %m "$1" >/dev/null 2>&1; then
    stat -f %m "$1"          # BSD/macOS
  else
    stat -c %Y "$1"          # GNU/Linux
  fi
}

while true; do
  sleep "$POLL_INTERVAL"

  # bail out cleanly if the tty or the activity file have gone away
  [ -e "$tty_dev" ] || exit 0
  [ -e "$ACTIVITY_FILE" ] || exit 0

  now=$(date +%s)
  mtime=$(get_mtime "$ACTIVITY_FILE" 2>/dev/null) || continue
  idle=$(( now - mtime ))

  if [ "$idle" -ge "$MATRIX_IDLE_SECONDS" ]; then
    "$MATRIX_BIN" < "$tty_dev" > "$tty_dev" 2>/dev/null
    touch "$ACTIVITY_FILE" 2>/dev/null   # reset countdown after exiting
  fi
done

