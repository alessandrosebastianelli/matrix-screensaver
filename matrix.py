#!/usr/bin/env python3
"""Matrix digital rain screensaver. Exits on any keypress."""
import curses
import random
import time

KATAKANA = "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポ"
LATIN = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
CHARS = KATAKANA + LATIN

FPS = 24
SPAWN_CHANCE = 0.04


class Column:
    __slots__ = ("x", "y", "speed", "length", "next_step", "glyphs")

    def __init__(self, x, height):
        self.reset(x, height)

    def reset(self, x, height):
        self.x = x
        self.y = random.randint(-height, 0)
        self.speed = random.uniform(0.4, 1.6)  # rows per tick
        self.length = random.randint(6, 28)
        self.next_step = 0.0
        self.glyphs = [random.choice(CHARS) for _ in range(self.length)]

    def step(self, dt):
        self.next_step += dt * self.speed
        moved = int(self.next_step)
        if moved:
            self.next_step -= moved
            self.y += moved
            # occasionally mutate a glyph to mimic the flicker effect
            if random.random() < 0.3:
                idx = random.randrange(self.length)
                self.glyphs[idx] = random.choice(CHARS)


def init_colors():
    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_WHITE, -1)   # head
    curses.init_pair(2, curses.COLOR_GREEN, -1)   # bright trail
    curses.init_pair(3, curses.COLOR_GREEN, -1)   # dim trail


def draw(stdscr, columns, height, width):
    stdscr.erase()
    for col in columns:
        for i, glyph in enumerate(col.glyphs):
            row = col.y - i
            if 0 <= row < height and 0 <= col.x < width:
                if i == 0:
                    attr = curses.color_pair(1) | curses.A_BOLD
                elif i < col.length * 0.35:
                    attr = curses.color_pair(2) | curses.A_BOLD
                elif i < col.length * 0.75:
                    attr = curses.color_pair(3)
                else:
                    attr = curses.color_pair(3) | curses.A_DIM
                try:
                    stdscr.addstr(row, col.x, glyph, attr)
                except curses.error:
                    pass  # bottom-right corner write, harmless
    stdscr.refresh()


def main(stdscr):
    curses.curs_set(0)
    stdscr.nodelay(True)
    init_colors()
    height, width = stdscr.getmaxyx()
    columns = [Column(x, height) for x in range(width)]

    last = time.time()
    frame_time = 1.0 / FPS
    while True:
        ch = stdscr.getch()
        if ch != -1:
            return  # any keypress ends the screensaver

        now = time.time()
        dt = now - last
        last = now

        new_h, new_w = stdscr.getmaxyx()
        if (new_h, new_w) != (height, width):
            height, width = new_h, new_w
            columns = [Column(x, height) for x in range(width)]

        for col in columns:
            col.step(dt * FPS)
            if col.y - col.length > height:
                col.reset(col.x, height)

        draw(stdscr, columns, height, width)
        time.sleep(max(0.0, frame_time - (time.time() - now)))


if __name__ == "__main__":
    try:
        curses.wrapper(main)
    except KeyboardInterrupt:
        pass
