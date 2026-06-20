# matrix-screensaver

A Matrix-style digital rain screensaver for the terminal (macOS, Linux,
plain terminal, SSH, and iTerm2). Activates automatically after a period of
inactivity and exits on any keypress.

## How it works

- **`matrix.py`** — the animation itself, built with Python's `curses`.
  Katakana and Latin glyphs fall down the screen with randomized speed and
  column length, a white "head" character, a green trail fading from bright
  to dim, and occasional glyph flicker for the classic Matrix look.

- **Idle detection** — a lightweight background watcher polls an activity
  timestamp file (touched by a shell prompt hook every time you run a
  command). When idle time passes the threshold, the watcher sends
  `SIGUSR1` to your interactive shell — the shell's own trap then runs
  `matrix.py` in its own foreground context. The watcher itself never
  touches the terminal, so it can't steal terminal control or crash the
  shell. (An earlier version used bash's `TMOUT`, but `TMOUT` on macOS's
  stock bash 3.2 force-exits the shell on timeout regardless of any trap —
  that's why this approach uses a signal instead.)

- **`screensaver-watch.sh`** — the background polling loop described above.

- **`enable-watcher.sh`** — detects which shell config files you have
  (`~/.config/bash/common.bashrc`, `~/.bashrc`, `~/.zshrc`) and lets you add
  the hook to one, several, or all of them via a terminal menu.

- **`install.sh`** — copies `matrix.py`, `screensaver-watch.sh`, and
  `enable-watcher.sh` to `~/.local/bin`, then runs `enable-watcher.sh`
  automatically.

## Requirements

- Python 3 (with the standard `curses` module — included by default on
  macOS and Linux)
- bash and/or zsh

## Installation

```bash
unzip matrix-screensaver.zip
cd matrix-screensaver
chmod +x install.sh
./install.sh
```

This installs `~/.local/bin/matrix.py`, `~/.local/bin/screensaver-watch.sh`,
and `~/.local/bin/enable-watcher.sh`, then immediately runs the menu to
wire up the auto-start hook in your shell config(s) — no extra manual step
needed.

Make sure `~/.local/bin` is on your `PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then reload your shell:

```bash
source ~/.bashrc   # or source ~/.zshrc
```

### Re-running the menu later

If you add a new shell config later, or want to change which files have the
hook, just re-run:

```bash
~/.local/bin/enable-watcher.sh
```

It's idempotent — re-running it won't duplicate the block if it's already
present in a given file.

### Configuration

Set this **before sourcing** your shell config (e.g. in `~/.profile`, or
above the matrix-screensaver block in the config file itself) to change the
idle timeout (default 120 seconds):

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
pkill -f screensaver-watch.sh
rm ~/.local/bin/matrix.py ~/.local/bin/screensaver-watch.sh ~/.local/bin/enable-watcher.sh
```

Then remove the `# --- matrix-screensaver: begin ---` … `# --- matrix-screensaver: end ---`
block from whichever shell config file(s) you added it to.

## Notes

- Idle time is measured from the last command run at the shell prompt (the
  activity file is touched once per prompt), not raw keystrokes. Just
  moving the cursor or typing without pressing Enter doesn't reset it.
- The screensaver only triggers via the shell's own `SIGUSR1` trap while
  it's idle — running programs in the foreground (e.g. `vim`) are
  unaffected, since the signal interrupts the shell's prompt, not theirs.
- Works identically in iTerm2 since it relies only on standard shell traps,
  signals, and ANSI rendering — no iTerm-specific integration required.
