# pyright: reportMissingImports=false

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
right_status_length = -1

opts = get_options()

ICON = "   Kitty Tabs"
icon_fg = as_rgb(color_as_int(opts.color4))
icon_bg = as_rgb(color_as_int(opts.tab_bar_background))

# Bottom decoration bar
decoration_fg = as_rgb(color_as_int(opts.color4))
decoration_bg = as_rgb(color_as_int(opts.tab_bar_background))


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
    """Draw tab content for horizontal tab bar."""
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
    return end


def _draw_tab_content(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_tab_length: int,
    index: int,
) -> None:
    """Draw the tab indicator + title on the current line."""
    is_active = tab.is_active
    max_tab_length = max(1, max_tab_length)

    screen.cursor.x = 1
    screen.cursor.italic = False
    screen.cursor.bold = is_active

    # Active indicator
    if is_active:
        screen.draw("▌")
    else:
        screen.draw(" ")

    # Draw title
    used = 4
    available = max(1, max_tab_length - used)
    draw_title(draw_data, screen, tab, index, available)

    # Truncate if overflows
    extra = screen.cursor.x - before - max_tab_length
    if extra > 0:
        screen.cursor.x -= extra + 1
        screen.draw("…")

    # Pad to full width
    if screen.cursor.x < before + max_tab_length:
        if is_active:
            screen.draw(" " * (before + max_tab_length - screen.cursor.x - 1))
            screen.draw(">")
            screen.draw(" ")
        else:
            screen.draw(" " * (before + max_tab_length - screen.cursor.x + 1))

    screen.cursor.bold = False
    screen.cursor.italic = False



def _draw_vertical_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    """Draw a single tab in vertical mode using kitty's native 2-line-per-tab.

    Every tab uses the same layout:
      Line 1: tab content
      Line 2: empty spacing line

    For the last tab, also draw the decoration bar at the bottom.

    Because kitty manages cursor.y and tab_extents internally,
    click detection is correct.
    """
    max_tab_length = max(1, max_tab_length)
    # Line 1: tab content
    _draw_tab_content(draw_data, screen, tab, before, max_tab_length, index)
    if is_last:
        screen.cursor.bg = 0
        screen.cursor.fg = 0
    return screen.cursor.x


def _draw_right_status(screen: Screen, is_last: bool, cells: list) -> int:
    if not is_last:
        return screen.cursor.x
    draw_attributed_string(Formatter.reset, screen)
    screen.cursor.x = screen.columns - right_status_length
    screen.cursor.bg = 0
    for _i, (status, color_fg, _color_bg) in enumerate(cells):
        screen.draw(status)
    screen.cursor.fg = 0
    return screen.cursor.x


def _cell_length(cells):
    right_status_length = 2
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
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    is_vertical = draw_data.tab_bar_edge in ("left", "right")

    if is_vertical:
        return _draw_vertical_tab(
            draw_data, screen, tab, before, max_tab_length,
            index, is_last, extra_data,
        )
    else:
        return _draw_left_status(
            draw_data, screen, tab, before, max_tab_length,
            index, is_last, extra_data,
        )
