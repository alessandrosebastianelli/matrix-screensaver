#!/usr/bin/env bash
# screensaver-watch.sh
# Watches the controlling tty for inactivity and launches the Matrix
# screensaver after $MATRIX_IDLE_SECONDS of no keystrokes. Works in a
# plain terminal, over SSH, and in iTerm2 (no iTerm-specific APIs needed).

MATRIX_IDLE_SECONDS="${MATRIX_IDLE_SECONDS:-120}"
MATRIX_BIN="${MATRIX_BIN:-$HOME/.local/bin/matrix.py}"
POLL_INTERVAL=5

tty_dev="$(tty 2>/dev/null)"
[ -z "$tty_dev" ] || [ "$tty_dev" = "not a tty" ] && exit 0

get_atime() {
  if stat -f %a "$tty_dev" >/dev/null 2>&1; then
    stat -f %a "$tty_dev"          # BSD/macOS
  else
    stat -c %X "$tty_dev"          # GNU/Linux
  fi
}

while true; do
  sleep "$POLL_INTERVAL"

  # bail out cleanly if the tty has gone away (shell closed)
  [ -e "$tty_dev" ] || exit 0

  now=$(date +%s)
  atime=$(get_atime 2>/dev/null) || continue
  idle=$(( now - atime ))

  if [ "$idle" -ge "$MATRIX_IDLE_SECONDS" ]; then
    "$MATRIX_BIN" < "$tty_dev" > "$tty_dev" 2>/dev/null
    # loop resumes polling immediately after any keypress exits matrix.py
  fi
done
