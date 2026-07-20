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

bar_fg = as_rgb(color_as_int(opts.foreground))
bar_bg = as_rgb(color_as_int(opts.tab_bar_background))

ICON = "   Kitty Tabs"
icon_fg = as_rgb(color_as_int(opts.color4))
icon_bg = as_rgb(color_as_int(opts.tab_bar_background))

DATE = "  %Y-%m-%d "
date_fg = as_rgb(color_as_int(opts.color8))
date_bg = as_rgb(color_as_int(opts.foreground))

# Requires nerdfont: https://www.nerdfonts.com
SEPARATOR_LEFT = ""
SOFT_SEPARATOR_SYMBOL_LEFT = ""
SEPARATOR_SYMBOL_RIGHT = ""
SEPARATOR_DOT = ""
RIGHT_MARGIN = 0
REFRESH_TIME = 1


# Top decoration bar
decoration_fg = as_rgb(color_as_int(opts.color4))
decoration_bg = as_rgb(color_as_int(opts.tab_bar_background))


def _draw_header(screen: Screen, max_tab_length: int) -> None:
    """Draw the decoration header at the top of the vertical tab bar.

    Draws HEADER_ROWS rows at the current cursor position:
      Row 1: hostname icon (blue bg)
      Row 2: separator line
    After drawing, cursor.y is advanced by HEADER_ROWS.
    """
    # Row 1: hostname icon
    max_tab_length += 1
    screen.cursor.fg = decoration_bg
    screen.cursor.bg = decoration_fg
    screen.cursor.bold = True
    screen.cursor.italic = False
    screen.draw(ICON)
    # Pad to full width
    remaining = max_tab_length - len(ICON)
    if remaining > 0:
        screen.draw(" " * remaining)

    # Row 2: separator line
    screen.cursor.x = 0
    screen.cursor.y += 1
    screen.cursor.fg = as_rgb(color_as_int(opts.color4))
    screen.cursor.bg = bar_bg
    screen.cursor.bold = False
    screen.draw("─" * max_tab_length)

    # Advance cursor past the header
    screen.cursor.x = 0
    screen.cursor.y += 1


def _draw_icon(screen: Screen, index: int) -> int:
    """Draw the hostname icon at the top of the vertical tab bar (only for first tab)."""
    if index != 1:
        return 0

    screen.cursor.fg = icon_bg
    screen.cursor.bg = icon_fg
    screen.cursor.bold = True
    screen.cursor.italic = False
    screen.draw(ICON)
    screen.cursor.fg = icon_fg
    screen.cursor.bg = icon_bg
    screen.cursor.fg = 0

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
    """Draw tab content for horizontal tab bar (original behavior)."""
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
    screen.cursor.bg = bar_bg
    return end


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
    """Draw a single tab in vertical (left/right edge) mode.

    For the first tab (index == 1), draws a decoration header first,
    then draws tab 1 below it. For subsequent tabs, shifts cursor.y
    down to account for the header + spacing from previous tabs.

    kitty's update_vertical() sets cursor.y before each draw_tab call
    without knowing about our header/spacing, so we manually offset
    cursor.y to compensate.

    Layout (with TAB_SPACING=1):
        Row 0-1: decoration header (hostname + separator)
        Row 2:   tab 1
        Row 3:   (spacing)
        Row 4:   tab 2
        Row 5:   (spacing)
        Row 6:   tab 3
        ...
    """
    is_active = tab.is_active
    max_tab_length = max(1, max_tab_length)

    # Calculate total y-offset: header rows + spacing from previous tabs
    # Each previous tab (index 1..index-1) occupies 1 row + TAB_SPACING rows

    if index == 1:
        # Draw the header at the current position (row 0)
        _draw_header(screen, max_tab_length)
        # Now cursor.y is at row HEADER_ROWS, draw tab 1 here
    else:
        # Offset cursor.y to account for header + spacing from previous tabs
        screen.cursor.y += 2

    # --- Draw the tab content ---

    screen.cursor.x = 0
    screen.cursor.fg = bar_fg
    screen.cursor.bg = bar_bg

    screen.cursor.italic = False
    if is_active:
        screen.cursor.bold = True
    else:
        screen.cursor.bold = False

    # Draw indicator
    if is_active:
        screen.cursor.fg = as_rgb(color_as_int(opts.color4))
        screen.cursor.bg = bar_bg
        screen.draw("▌")
        screen.cursor.fg = as_rgb(draw_data.tab_fg(tab))
    else:
        screen.draw(" ")

    if is_active:
        screen.cursor.fg = as_rgb(color_as_int(opts.color4))
        screen.cursor.fg = as_rgb(draw_data.tab_fg(tab))

    # Draw title
    used = 4  # indicator(1) + icon(1) + space(1) + trailing space(1)
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
        else:
            screen.draw(" " * (before + max_tab_length - screen.cursor.x))


    screen.cursor.bold = False
    screen.cursor.italic = False
    return screen.cursor.x


def _draw_right_status(screen: Screen, is_last: bool, cells: list) -> int:
    if not is_last:
        return screen.cursor.x
    draw_attributed_string(Formatter.reset, screen)
    screen.cursor.x = screen.columns - right_status_length
    screen.cursor.bg = 0
    for _i, (status, color_fg, _color_bg) in enumerate(cells):
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
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    is_vertical = draw_data.tab_bar_edge in ("left", "right")

    if is_vertical:
        return _draw_vertical_tab(
            draw_data,
            screen,
            tab,
            before,
            max_tab_length,
            index,
            is_last,
            extra_data,
        )
    else:
        return _draw_left_status(
            draw_data,
            screen,
            tab,
            before,
            max_tab_length,
            index,
            is_last,
            extra_data,
        )
