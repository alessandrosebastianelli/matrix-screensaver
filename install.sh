#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"

mkdir -p "$BIN_DIR"
cp "$SCRIPT_DIR/matrix.py" "$BIN_DIR/matrix.py"
cp "$SCRIPT_DIR/screensaver-watch.sh" "$BIN_DIR/screensaver-watch.sh"
chmod +x "$BIN_DIR/matrix.py" "$BIN_DIR/screensaver-watch.sh"

cp "$SCRIPT_DIR/enable-watcher.sh" "$BIN_DIR/enable-watcher.sh"
chmod +x "$BIN_DIR/enable-watcher.sh"

echo "Installed matrix.py, screensaver-watch.sh, enable-watcher.sh to $BIN_DIR"
echo

"$BIN_DIR/enable-watcher.sh"

echo
echo "Optional: export MATRIX_IDLE_SECONDS=180 in your shell config to change the idle timeout (default 120s)."
