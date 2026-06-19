# pyright: reportMissingImports=false
import os
from datetime import datetime

from kitty.boss import get_boss
from kitty.fast_data_types import Screen, add_timer, get_options
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    Formatter,
    TabBarData,
    as_rgb,
    draw_attributed_string,
    draw_title,
)
from kitty.utils import color_as_int

# GLOBAL STATE!
timer_id = None
right_status_length = -1


opts = get_options()

bar_fg = as_rgb(color_as_int(opts.foreground))
bar_bg = as_rgb(color_as_int(opts.tab_bar_background))

ICON = " \uf489 " + os.uname().nodename + " "
icon_fg = as_rgb(color_as_int(opts.color4))
icon_bg = as_rgb(color_as_int(opts.tab_bar_background))

# CLOCK = " \ue641 %H:%M "
# clock_fg = as_rgb(color_as_int(opts.foreground))
# clock_bg = as_rgb(color_as_int(opts.color0))

DATE = " \uf073 %Y-%m-%d "
date_fg = as_rgb(color_as_int(opts.color3))
date_bg = as_rgb(color_as_int(opts.background))

# Requires nerdfont: https://www.nerdfonts.com
SEPARATOR_SYMBOL_LEFT1 = "▓"
SEPARATOR_SYMBOL_LEFT2 = "▒"
SEPARATOR_SYMBOL_LEFT3 = "░"
SEPARATOR_LEFT = ""
SEPARATOR_RIGHT = ""
SOFT_SEPARATOR_SYMBOL_LEFT = "\ue0b1"
SEPARATOR_SYMBOL_RIGHT = "\ue0b2"
SEPARATOR_DOT = "\ueb10"
RIGHT_MARGIN = 0
REFRESH_TIME = 1


def _draw_icon(screen: Screen, index: int) -> int:
    if index != 1:
        return 0
    # fg, bg = screen.cursor.fg, screen.cursor.bg

    # screen.cursor.bg = icon_bg
    # screen.draw(" ")
    screen.cursor.fg = icon_bg
    screen.cursor.bg = icon_fg
    screen.cursor.bold = True
    screen.draw(SEPARATOR_SYMBOL_LEFT1)
    screen.draw(SEPARATOR_SYMBOL_LEFT2)
    screen.draw(SEPARATOR_SYMBOL_LEFT3)
    screen.draw(ICON)
    screen.cursor.fg = icon_fg
    screen.cursor.bg = icon_bg
    screen.draw(SEPARATOR_LEFT)
    screen.cursor.fg = 0
    screen.cursor.x = len(ICON) + len(SEPARATOR_SYMBOL_LEFT1) +  len(SEPARATOR_SYMBOL_LEFT2) +  len(SEPARATOR_SYMBOL_LEFT3) + 2
    return screen.cursor.x


UNPLUGGED_ICONS = {
    10: "󰁺",
    20: "󰁻",
    30: "󰁼",
    40: "󰁽",
    50: "󰁾",
    60: "󰁿",
    70: "󰂀",
    80: "󰂁",
    90: "󰂂",
    100: "󰁹",
}
PLUGGED_ICONS = {
    10: "󰢜 ",
    20: "󰂆 ",
    30: "󰂇 ",
    40: "󰂈 ",
    50: "󰢝 ",
    60: "󰂉 ",
    70: "󰢞 ",
    80: "󰂊 ",
    90: "󰂋 ",
    100: "󰂅 ",
}
ERROR_ICON = "󰂑"

UNPLUGGED_COLORS = {
    15: as_rgb(color_as_int(opts.color1)),
    16: as_rgb(color_as_int(opts.color3)),
    80: as_rgb(color_as_int(opts.color3)),
    100: as_rgb(color_as_int(opts.color2)),
}
PLUGGED_COLORS = {
    15: as_rgb(color_as_int(opts.color1)),
    16: as_rgb(color_as_int(opts.color6)),
    80: as_rgb(color_as_int(opts.color6)),
    100: as_rgb(color_as_int(opts.color2)),
}


bat_fg = as_rgb(color_as_int(opts.color0))


def _get_closest(dictionary, value):
    keys = dictionary.keys()

    def min_distance(x):
        return abs(x - value)

    closestIdx = min(keys, key=min_distance)
    return dictionary[closestIdx]


def _draw_left_status(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    draw_title(draw_data, screen, tab, index)
    trailing_spaces = min(max_title_length - 1, draw_data.trailing_spaces)
    max_title_length -= trailing_spaces
    extra = screen.cursor.x - before - max_title_length
    if extra > 0:
        screen.cursor.x -= extra + 1
        screen.draw("…")
    if trailing_spaces:
        screen.draw(" " * trailing_spaces)
    end = screen.cursor.x
    screen.cursor.bold = screen.cursor.italic = False
    if not is_last:
        screen.cursor.bg = bar_bg
        screen.draw(SEPARATOR_DOT)
    screen.cursor.bg = 0
    return end


def _draw_right_status(screen: Screen, is_last: bool, cells: list) -> int:
    if not is_last:
        return 0
    draw_attributed_string(Formatter.reset, screen)
    screen.cursor.x = screen.columns - right_status_length
    screen.cursor.bg = 0
    for i, (status, color_fg, _color_bg) in enumerate(cells):
        screen.cursor.bg = bar_bg if i == 0 else cells[i-1][1]
        screen.cursor.fg = color_fg
        screen.draw(SEPARATOR_RIGHT)
        
        screen.cursor.fg = bar_bg
        screen.cursor.bg = color_fg
        screen.draw(status)
    screen.cursor.fg = 0
    return screen.cursor.x


def _cell_length(cells):
    right_status_length = RIGHT_MARGIN
    for cell in cells:
        right_status_length += len(str(cell[0])) + len(SEPARATOR_RIGHT)
    return right_status_length


def _redraw_tab_bar(_):
    tm = get_boss().active_tab_manager
    if tm is not None:
        tm.mark_tab_bar_dirty()


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    global timer_id
    global right_status_length
    if timer_id is None:
        timer_id = add_timer(_redraw_tab_bar, REFRESH_TIME, True)
    now = datetime.now()
    # clock = now.strftime(CLOCK)
    date = now.strftime(DATE)
    cells = []

    # cells.append((clock, clock_fg, clock_bg))
    cells.append((date, date_fg, date_bg))

    right_status_length = _cell_length(cells)

    _draw_icon(screen, index)
    _draw_left_status(
        draw_data,
        screen,
        tab,
        before,
        max_title_length,
        index,
        is_last,
        extra_data,
    )
    _draw_right_status(
        screen,
        is_last,
        cells,
    )
    return screen.cursor.x
