# pyright: reportMissingImports=false
import os

from kitty.boss import get_boss
from kitty.fast_data_types import Screen, get_options
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
date_fg = as_rgb(color_as_int(opts.color8))
date_bg = as_rgb(color_as_int(opts.foreground))

# Requires nerdfont: https://www.nerdfonts.com
SEPARATOR_LEFT = ""
# SEPARATOR_RIGHT = ""

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
    screen.cursor.italic = False
    screen.draw(ICON)
    screen.cursor.fg = icon_fg
    screen.cursor.bg = icon_bg
    screen.draw("\n")
    screen.cursor.fg = 0
    # screen.cursor.x = len(ICON)

    return screen.cursor.x


def _draw_left_status(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    _extra_data: ExtraData,
) -> int:
    screen.cursor.bold = screen.cursor.italic = False
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
    # if not is_last:
    #     screen.cursor.bg = bar_bg
    #     screen.draw(SEPARATOR_DOT)
    screen.cursor.bg = bar_bg
    return end


def _draw_right_status(screen: Screen, is_last: bool, cells: list) -> int:
    if not is_last:
        return screen.cursor.x
    draw_attributed_string(Formatter.reset, screen)
    screen.cursor.x = screen.columns - right_status_length
    screen.cursor.bg = 0
    for _i, (status, color_fg, _color_bg) in enumerate(cells):
        # screen.cursor.bg = bar_bg if i == 0 else cells[i-1][1]
        # screen.cursor.fg = color_fg
        # screen.draw(SEPARATOR_RIGHT)

        screen.cursor.fg = bar_bg
        screen.cursor.bg = color_fg
        screen.draw(status)
    screen.cursor.fg = 0
    return screen.cursor.x


def _cell_length(cells):
    right_status_length = RIGHT_MARGIN
    for cell in cells:
        right_status_length += len(str(cell[0]))
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
    # global timer_id
    # global right_status_length
    # if timer_id is None:
    #     timer_id = add_timer(_redraw_tab_bar, REFRESH_TIME, True)
    # now = datetime.now()
    # clock = now.strftime(CLOCK)
    # date = now.strftime(DATE)
    cells = []
    # cells.append((clock, clock_fg, clock_bg))
    # cells.append((date, date_fg, date_bg))
    # right_status_length = _cell_length(cells)

    # _draw_icon(screen, index)
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
    # _draw_right_status(
    #     screen,
    #     is_last,
    #     cells,
    # )
    return screen.cursor.x
