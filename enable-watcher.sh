#!/usr/bin/env bash
set -e

LINE='[[ $- == *i* ]] && [ -z "$MATRIX_WATCH_PID" ] && { "$HOME/.local/bin/screensaver-watch.sh" & MATRIX_WATCH_PID=$!; disown; }'

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
  if grep -qxF "$LINE" "$f" 2>/dev/null; then
    echo "Already present in $f, skipping."
  else
    echo "$LINE" >> "$f"
    echo "Added to $f"
  fi
done

echo
echo "Done. Run: source <file> (or open a new shell) to activate."
