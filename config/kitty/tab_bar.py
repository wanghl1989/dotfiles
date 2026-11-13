# pyright: reportMissingImports=false
"""Vertical tabs: native labels and hit regions, shader-drawn sliding fill.

The shader reads a record in the two padding columns of the first five rows,
then erases that record before displaying the sidebar.
"""
import time
from typing import NamedTuple

from kitty.fast_data_types import (
    add_timer, get_boss, get_options, mark_tab_bar_dirty, viewport_for_window,
)
from kitty.tab_bar import TabBar, as_rgb, draw_title
from kitty.shaders.slang import CUSTOM_END_PROGRAM, load_shader_programs

SHADER = "vertical-tab-slide"
SLIDE_SECONDS = 0.1
FRAME_SECONDS = 1 / 120
RECORD_ROWS = 5
MAX_COORDINATE = 8192


class Slide(NamedTuple):
    layout: tuple
    tab_id: int
    source: tuple[float, float]
    target: tuple[float, float]
    started: float

    def bounds(self, now):
        remaining = 1 - min(1.0, max(0.0, (now - self.started) / SLIDE_SECONDS))
        return tuple(end + (start - end) * remaining**3
                     for start, end in zip(self.source, self.target))


def marker_color(value, signature):
    """Encode 13 bits and a two-bit signature in robust sRGB color levels."""
    packed = int(round(value)) | (signature << 13)
    channels = [96 + 5 * ((packed >> shift) & 31) for shift in (10, 5, 0)]
    return as_rgb((channels[0] << 16) | (channels[1] << 8) | channels[2])


def draw_tab(draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data):
    vertical = draw_data.tab_bar_edge in ("left", "right")
    screen.cursor.bold = tab.is_active if vertical else False
    screen.cursor.italic = False
    if vertical:
        # Two padding columns carry metadata; the final column stays blank
        # for an untouched background sample, including its actual opacity.
        screen.cursor.x = 2
        available = max(1, min(max_tab_length, screen.columns - 1) - 2)
        limit = min(draw_data.max_tab_title_length or available, available)
        draw_data = draw_data._replace(max_tab_title_length=limit)
    else:
        available = max(1, max_tab_length)
    draw_title(draw_data, screen, tab, index, available)
    if vertical:
        # draw_title places its ellipsis but may leave already drawn suffix
        # cells behind. Clear them, including the background sampling column.
        screen.erase_in_line(0, False)
        # Native vertical layout clears the sidebar after measuring titles.
        # That clear uses cursor.bg: never leave the last tab's fill selected,
        # or it will also color every gap and row below the last visible tab.
        screen.cursor.bg = 0
    screen.cursor.bold = screen.cursor.italic = False
    return screen.cursor.x


draw_tab._vertical_slide = True
native_update_vertical = getattr(TabBar.update_vertical, "_native_vertical_slide", TabBar.update_vertical)


def queue_frame(bar):
    if getattr(bar, "_vertical_slide_timer", None):
        return

    def next_frame(_timer_id):
        bar._vertical_slide_timer = None
        manager = get_boss().os_window_map.get(bar.os_window_id)
        if (manager is not None and manager.tab_bar is bar
                and not manager.tab_bar_hidden and manager.tab_bar_should_be_visible):
            manager.update_tab_bar_data()
            mark_tab_bar_dirty(bar.os_window_id, True)

    bar._vertical_slide_timer = add_timer(next_frame, FRAME_SECONDS, False)


def shader_is_loaded():
    # An option naming a shader does not imply successful compilation. Kitty
    # removes a failed program from this registry; keep native highlighting
    # until our shader is actually installed instead of exposing data cells.
    compiled = load_shader_programs.last_built_custom_shaders.get(CUSTOM_END_PROGRAM)
    if compiled is None:
        return False
    groups = compiled[2].get("pipeline", {}).get("groups", ())
    return any(SHADER in group["shaders"] for group in groups)


def update_vertical(self, data):
    screen = self.screen
    geometry = self.window_geometry
    _, _, viewport_width, viewport_height, cell_width, cell_height = viewport_for_window(self.os_window_id)
    enabled = (
        getattr(self.draw_func, "_vertical_slide", False)
        and SHADER in get_options().custom_shaders
        and shader_is_loaded()
        and self.draw_data.tab_bar_edge == "left"
        and geometry.left == 0
        and screen.lines >= RECORD_ROWS and screen.columns >= 5
        and self.max_tab_title_lines == 1
        and 8 <= cell_height <= 256 and 2 <= cell_width <= 256
        and 0 <= geometry.top < 512
        and max(viewport_width, viewport_height) < MAX_COORDINATE
    )
    if not enabled:
        self._vertical_slide = None
        return native_update_vertical(self, data)

    original = self.draw_data
    # Draw neutral labels. The shader supplies the live theme colors.
    self.draw_data = original._replace(
        active_bg=original.default_bg, inactive_bg=original.default_bg,
        active_fg=original.inactive_fg,
    )
    neutral = [tab._replace(active_bg=None, inactive_bg=None,
                           active_fg=None, inactive_fg=None) for tab in data]
    try:
        changed = native_update_vertical(self, neutral)
    finally:
        self.draw_data = original
        self.last_laid_out_tabs = data

    active = next((tab for tab in data if tab.is_active), None)
    extent = next((item.y for item in self.tab_extents
                   if active is not None and item.tab_id == active.tab_id), None)
    if extent is None:
        self._vertical_slide = None
        return native_update_vertical(self, data)

    target = (geometry.top + extent.start * cell_height,
              geometry.top + (extent.end + 1) * cell_height)
    layout = (geometry, cell_width, cell_height, tuple(tab.tab_id for tab in data))
    now = time.monotonic()
    old = getattr(self, "_vertical_slide", None)
    if old is None or old.layout != layout:
        slide = Slide(layout, active.tab_id, target, target, now)
    elif old.tab_id != active.tab_id:
        slide = Slide(layout, active.tab_id, old.bounds(now), target, now)
    else:
        slide = old._replace(target=target)
    moving = slide.source != target and now - slide.started < SLIDE_SECONDS
    bounds = slide.bounds(now) if moving else target
    self._vertical_slide = slide if moving else slide._replace(source=target)

    record = (
        marker_color(cell_height, 3), marker_color(geometry.top, 2),
        marker_color(cell_width, 1), marker_color(geometry.right, 2),
        marker_color(bounds[0], 1), marker_color(bounds[1], 2),
        as_rgb(int(original.default_bg)), as_rgb(original.tab_bg(active)),
        as_rgb(int(original.inactive_fg)), as_rgb(original.tab_fg(active)),
    )
    # Native hit regions are already finalized. Never change them or rely on
    # is_last (always True vertically) to decide when the whole bar is done.
    saved = (screen.cursor.x, screen.cursor.y, screen.cursor.bg)
    try:
        for offset, color in enumerate(record):
            screen.cursor.x, screen.cursor.y = offset % 2, offset // 2
            screen.cursor.bg = color
            screen.draw(" ")
    finally:
        screen.cursor.x, screen.cursor.y, screen.cursor.bg = saved
    if moving:
        queue_frame(self)
    return changed


update_vertical._native_vertical_slide = native_update_vertical
TabBar.update_vertical = update_vertical
