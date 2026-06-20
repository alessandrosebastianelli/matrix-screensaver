#!/usr/bin/env bash
set -e

read -r -d '' BLOCK <<'EOF' || true
# --- matrix-screensaver: begin ---
if [[ $- == *i* ]]; then
  export MATRIX_ACTIVITY_FILE="/tmp/.matrix-activity-$$"
  export MATRIX_SHELL_PID="$$"
  touch "$MATRIX_ACTIVITY_FILE" 2>/dev/null
  matrix_touch_activity() { touch "$MATRIX_ACTIVITY_FILE" 2>/dev/null; }
  matrix_run() { "$HOME/.local/bin/matrix.py"; touch "$MATRIX_ACTIVITY_FILE" 2>/dev/null; }
  if [ -n "$ZSH_VERSION" ]; then
    autoload -Uz add-zsh-hook 2>/dev/null && add-zsh-hook precmd matrix_touch_activity
    TRAPUSR1() { matrix_run; }
  elif [ -n "$BASH_VERSION" ]; then
    case ";$PROMPT_COMMAND;" in
      *";matrix_touch_activity;"*) ;;
      *) PROMPT_COMMAND="matrix_touch_activity;${PROMPT_COMMAND}" ;;
    esac
    trap matrix_run USR1
  fi
  if [ -z "$MATRIX_WATCH_PID" ]; then
    "$HOME/.local/bin/screensaver-watch.sh" &
    MATRIX_WATCH_PID=$!
    disown
  fi
fi
# --- matrix-screensaver: end ---
EOF

declare -a candidates=()
[ -f "$HOME/.config/bash/common.bashrc" ] && candidates+=("$HOME/.config/bash/common.bashrc")
[ -f "$HOME/.bashrc" ] && candidates+=("$HOME/.bashrc")
[ -f "$HOME/.zshrc" ] && candidates+=("$HOME/.zshrc")

if [ ${#candidates[@]} -eq 0 ]; then
  echo "No shell config files found (~/.bashrc, ~/.zshrc, ~/.config/bash/common.bashrc)."
  exit 1
fi

echo "Found shell config files:"
for i in "${!candidates[@]}"; do
  printf "  %d) %s\n" "$((i+1))" "${candidates[$i]}"
done
echo "  a) All of the above"
echo "  q) Quit without changes"
echo
read -rp "Add the watcher hook to which? [1-${#candidates[@]}/a/q]: " choice

case "$choice" in
  q|Q) echo "No changes made."; exit 0 ;;
  a|A) selected=("${candidates[@]}") ;;
  *)
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#candidates[@]} ]; then
      selected=("${candidates[$((choice-1))]}")
    else
      echo "Invalid choice."
      exit 1
    fi
    ;;
esac

for f in "${selected[@]}"; do
  if grep -qF "matrix-screensaver: begin" "$f" 2>/dev/null; then
    echo "Already present in $f, skipping."
  else
    printf '\n%s\n' "$BLOCK" >> "$f"
    echo "Added to $f"
  fi
done

echo
echo "Done. Open a new shell (or run: source <file>) to activate."
