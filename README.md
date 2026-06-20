# matrix-screensaver

A Matrix-style digital rain screensaver for the terminal (macOS, Linux, plain
terminal, SSH, and iTerm2). Activates automatically after a period of
inactivity and exits on any keypress.

## How it works

- **`matrix.py`** — the animation itself, built with Python's `curses`.
  Katakana and Latin glyphs fall down the screen with randomized speed and
  column length, a white "head" character, a green trail fading from bright
  to dim, and occasional glyph flicker for the classic Matrix look.

- **`screensaver-watch.sh`** — a background watcher loop. It polls (every
  5 seconds) the modification time of an activity timestamp file that the
  shell touches on every prompt. When idle time passes the threshold, it
  launches `matrix.py` on your tty; any keypress ends the animation and the
  watcher resumes polling. This avoids relying on tty `atime`, which macOS
  (APFS) does not update reliably.

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

`install.sh` already runs the menu for you (see above). If you need to
re-run it later — e.g. after adding a new shell config — call it directly:

```bash
~/.local/bin/enable-watcher.sh
```

It detects which shell config files you have (`~/.config/bash/common.bashrc`,
`~/.bashrc`, `~/.zshrc`) and lets you pick one, several, or all of them via a
simple terminal menu. It's idempotent — re-running it won't duplicate the
line if it's already present.

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

- Idle time is measured from the last shell prompt (each time a command
  finishes and a new prompt is shown), not raw keystrokes. In practice this
  means the countdown resets whenever you run a command; just moving the
  cursor or typing without pressing Enter does not reset it.
- The watcher only triggers at the shell prompt — it does not interrupt
  programs actively running in the foreground.
- Works identically in iTerm2 since it relies only on standard shell hooks
  and ANSI rendering, no iTerm-specific integration required.
