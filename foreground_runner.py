#!/usr/bin/env python3
"""
foreground_runner.py <tty_path> <program> [args...]

Launches <program> as the foreground process group of <tty_path>, waits
for it to exit, then restores the terminal's original foreground process
group. This is required because a background job (like our idle watcher)
cannot read keystrokes from its controlling terminal -- only the
foreground process group can. Without this handoff the launched program
gets silently stopped (SIGTTIN/SIGTTOU) or never receives keypresses.
"""
import os
import signal
import sys


def main():
    if len(sys.argv) < 3:
        print("usage: foreground_runner.py <tty_path> <program> [args...]", file=sys.stderr)
        sys.exit(1)

    tty_path = sys.argv[1]
    prog_args = sys.argv[2:]

    # We are likely running in a background process group ourselves.
    # Ignore job-control signals so the tcsetpgrp() calls below don't
    # stop this process.
    for sig in (signal.SIGTTOU, signal.SIGTTIN, signal.SIGTSTP):
        signal.signal(sig, signal.SIG_IGN)

    tty_fd = os.open(tty_path, os.O_RDWR)
    try:
        orig_pgrp = os.tcgetpgrp(tty_fd)
    except OSError:
        orig_pgrp = None

    pid = os.fork()
    if pid == 0:
        # Child: own process group, take terminal foreground, exec target.
        try:
            os.setpgid(0, 0)
        except OSError:
            pass
        os.dup2(tty_fd, 0)
        os.dup2(tty_fd, 1)
        os.dup2(tty_fd, 2)
        try:
            os.tcsetpgrp(tty_fd, os.getpgrp())
        except OSError:
            pass
        try:
            os.execvp(prog_args[0], prog_args)
        except OSError as e:
            print(f"exec failed: {e}", file=sys.stderr)
            os._exit(1)
    else:
        # Parent (the watcher): hand the terminal to the child, wait,
        # then take it back so the interactive shell works normally again.
        try:
            os.setpgid(pid, pid)
        except OSError:
            pass
        try:
            os.tcsetpgrp(tty_fd, pid)
        except OSError:
            pass
        try:
            os.waitpid(pid, 0)
        finally:
            if orig_pgrp is not None:
                try:
                    os.tcsetpgrp(tty_fd, orig_pgrp)
                except OSError:
                    pass
            os.close(tty_fd)


if __name__ == "__main__":
    main()
