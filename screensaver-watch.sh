#!/usr/bin/env bash
# screensaver-watch.sh
# Polls an activity timestamp file (touched by a shell prompt hook). When
# idle time passes the threshold, sends SIGUSR1 to the interactive shell
# that started this watcher -- the shell's own trap then runs matrix.py
# in its own foreground context. This watcher never touches the tty
# itself, so it cannot steal terminal control or crash the shell.

MATRIX_IDLE_SECONDS="${MATRIX_IDLE_SECONDS:-120}"
POLL_INTERVAL=5

SHELL_PID="${MATRIX_SHELL_PID:?MATRIX_SHELL_PID not set}"
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

  # stop once the shell that started us is gone
  kill -0 "$SHELL_PID" 2>/dev/null || exit 0
  [ -e "$ACTIVITY_FILE" ] || exit 0

  now=$(date +%s)
  mtime=$(get_mtime "$ACTIVITY_FILE" 2>/dev/null) || continue
  idle=$(( now - mtime ))

  if [ "$idle" -ge "$MATRIX_IDLE_SECONDS" ]; then
    kill -USR1 "$SHELL_PID" 2>/dev/null
    touch "$ACTIVITY_FILE" 2>/dev/null   # avoid re-signaling every poll
  fi
done
