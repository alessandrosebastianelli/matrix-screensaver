# matrix-screensaver

A Matrix-style digital rain screensaver for the terminal (macOS, Linux, plain
terminal, SSH, and iTerm2). Activates automatically after a period of
inactivity and exits on any keypress.

## How it works

- **`matrix.py`** — the animation itself, built with Python's `curses`.
  Katakana and Latin glyphs fall down the screen with randomized speed and
  column length, a white "head" character, a green trail fading from bright
  to dim, and occasional glyph flicker for the classic Matrix look.

- **`screensaver-watch.sh`** — a background watcher loop. Every 5 seconds it
  checks the access time (`atime`) of the current tty device. Reading the
  tty's atime is what changes whenever you type, so it works as an
  inactivity signal without needing X11, `xprintidle`, or any iTerm-specific
  API. When idle time passes the threshold, it launches `matrix.py` on that
  same tty; any keypress ends the animation and the watcher resumes polling.

- **`install.sh`** — copies both scripts to `~/.local/bin` and prints the
  shell snippet needed to auto-start the watcher in new interactive shells.

## Requirements

- Python 3 (with the standard `curses` module — included by default on
  macOS and Linux)
- bash, `stat`, `tty`, `date` (all standard on macOS/Linux)

## Installation

```bash
unzip matrix-screensaver.zip
cd matrix-screensaver
chmod +x install.sh
./install.sh
```

This installs:

- `~/.local/bin/matrix.py`
- `~/.local/bin/screensaver-watch.sh`

and prints a line to add to your shell config.

### Enable auto-start

Add the printed line to `~/.bashrc` and/or `~/.zshrc` (or to your dotfiles'
shared `common.bashrc`, since it's sourced from both):

```bash
[[ $- == *i* ]] && [ -z "$MATRIX_WATCH_PID" ] && { "$HOME/.local/bin/screensaver-watch.sh" & MATRIX_WATCH_PID=$!; disown; }
```

This starts one background watcher per interactive shell session, guarded so
it won't double-spawn if the file is sourced twice.

Make sure `~/.local/bin` is on your `PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then reload your shell:

```bash
source ~/.bashrc   # or source ~/.zshrc
```

### Configuration

Set this **before** the auto-start line to change the idle timeout (default
120 seconds):

```bash
export MATRIX_IDLE_SECONDS=180
```

## Manual test

Run the animation directly, without waiting for idle detection:

```bash
~/.local/bin/matrix.py
```

Press any key to exit.

## Uninstall

```bash
rm ~/.local/bin/matrix.py ~/.local/bin/screensaver-watch.sh
pkill -f screensaver-watch.sh
```

Then remove the auto-start line from your shell config.

## Notes

- The watcher only triggers at the shell prompt — it does not interrupt
  programs actively running in the foreground (e.g. a long `vim` session
  keeps the tty's atime fresh as you type, so the screensaver won't fire
  mid-edit).
- Works identically in iTerm2 since it relies only on standard tty/ANSI
  behavior, no iTerm-specific integration required.
