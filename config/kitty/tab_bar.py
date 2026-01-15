# pyright: reportMissingImports=false
import os
from datetime import datetime
from kitty.boss import get_boss
from kitty.fast_data_types import Screen, add_timer, get_options
from kitty.utils import color_as_int
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    Formatter,
    TabBarData,
    as_rgb,
    draw_attributed_string,
    draw_title,
)


# GLOBAL STATE!
timer_id = None
right_status_length = -1


opts = get_options()

ICON = "  \uf489 " + os.uname().nodename + " "
icon_fg = as_rgb(color_as_int(opts.color6))
icon_bg = as_rgb(color_as_int(opts.color0))

CLOCK = " \uf017 %H:%M "
clock_fg = as_rgb(color_as_int(opts.color15))
clock_bg = as_rgb(color_as_int(opts.color5))

DATE = " \uf073 %Y-%m-%d "
date_fg = as_rgb(color_as_int(opts.color0))
date_bg = as_rgb(color_as_int(opts.color2))

# Requires nerdfont: https://www.nerdfonts.com
SEPARATOR_SYMBOL_LEFT = "\ue0b0"
SOFT_SEPARATOR_SYMBOL_LEFT = "\ue0b1"
SEPARATOR_SYMBOL_RIGHT = "\ue0b2"
RIGHT_MARGIN = 0
REFRESH_TIME = 1


def _draw_icon(screen: Screen, index: int) -> int:
    if index != 1:
        return 0
    fg, bg = screen.cursor.fg, screen.cursor.bg
    screen.cursor.fg = icon_fg
    screen.cursor.bg = icon_bg
    screen.draw(ICON)
    screen.cursor.fg = icon_bg
    screen.cursor.bg = bg
    screen.draw(SEPARATOR_SYMBOL_LEFT)
    screen.cursor.fg = fg
    screen.cursor.x = len(ICON) + len(SEPARATOR_SYMBOL_LEFT)
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
    100: "󰂅 "
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
    if screen.cursor.x >= screen.columns - right_status_length:
        return screen.cursor.x
    tab_bg = screen.cursor.bg
    tab_fg = screen.cursor.fg
    default_bg = as_rgb(int(draw_data.default_bg))
    if extra_data.next_tab:
        next_tab_bg = as_rgb(draw_data.tab_bg(extra_data.next_tab))
        needs_soft_separator = next_tab_bg == tab_bg
    else:
        next_tab_bg = default_bg
        needs_soft_separator = False

    screen.draw(" ")
    screen.cursor.bg = tab_bg
    draw_title(draw_data, screen, tab, index)
    if not needs_soft_separator:
        screen.draw(" ")
        screen.cursor.fg = tab_bg
        screen.cursor.bg = next_tab_bg
        screen.draw(SEPARATOR_SYMBOL_LEFT)
    else:
        prev_fg = screen.cursor.fg
        if tab_bg == tab_fg:
            screen.cursor.fg = default_bg
        screen.draw(" " + SOFT_SEPARATOR_SYMBOL_LEFT)
        screen.cursor.fg = prev_fg
    end = screen.cursor.x
    return end


def _draw_right_status(screen: Screen, is_last: bool, cells: list) -> int:
    if not is_last:
        return 0
    draw_attributed_string(Formatter.reset, screen)
    screen.cursor.x = screen.columns - right_status_length
    screen.cursor.fg = 0
    for status, color_fg, color_bg in cells:
        screen.cursor.fg = color_bg
        screen.draw(SEPARATOR_SYMBOL_RIGHT)
        screen.cursor.fg = color_fg
        screen.cursor.bg = color_bg
        screen.draw(status)
    screen.cursor.bg = 0
    return screen.cursor.x


def _cell_length(cells):
    right_status_length = RIGHT_MARGIN
    for cell in cells:
        right_status_length += len(str(cell[0])) + len(str(SEPARATOR_SYMBOL_RIGHT))
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
    clock = now.strftime(CLOCK)
    date = now.strftime(DATE)
    cells = []

    cells.append((date, date_fg, date_bg))
    # cells.append((clock, clock_fg, clock_bg))

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

