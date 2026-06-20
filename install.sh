#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"

mkdir -p "$BIN_DIR"
cp "$SCRIPT_DIR/matrix.py" "$BIN_DIR/matrix.py"
cp "$SCRIPT_DIR/screensaver-watch.sh" "$BIN_DIR/screensaver-watch.sh"
chmod +x "$BIN_DIR/matrix.py" "$BIN_DIR/screensaver-watch.sh"

echo "Installed matrix.py and screensaver-watch.sh to $BIN_DIR"
echo
echo "Add this line to ~/.bashrc and/or ~/.zshrc to auto-start the watcher"
echo "in every new interactive shell (works in plain terminal and iTerm2):"
echo
echo '  [[ $- == *i* ]] && [ -z "$MATRIX_WATCH_PID" ] && { "$HOME/.local/bin/screensaver-watch.sh" & MATRIX_WATCH_PID=$!; disown; }'
echo
echo "Optional: export MATRIX_IDLE_SECONDS=180 before that line to change the idle timeout (default 120s)."
