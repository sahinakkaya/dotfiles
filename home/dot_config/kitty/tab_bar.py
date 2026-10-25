import math
from kitty.fast_data_types import (
    Screen,
    SingleKey,
    add_timer,
    get_boss,
    get_options,
    remove_timer,
    wakeup_main_loop,
)
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    TabBarData,
    as_rgb,
    draw_tab_with_powerline,
)
from kitty.types import human_repr_of_single_key

opts = get_options()

timer_id = None

# Keep status text and the PREFIX badge distinct on Kanagawa's dark background.
status_accent = as_rgb(int("7E9CD8", 16))
window_icon = ""
layout_icon = ""

active_tab_layout_name = ""
active_tab_num_windows = 1


def prefix_status() -> str:
    modes = get_boss().mappings.keyboard_mode_stack
    for index, mode in enumerate(modes):
        if mode.name == "kitty_prefix":
            keys = [
                human_repr_of_single_key(
                    SingleKey(event.mods, False, event.key), opts.kitty_mod
                )
                for nested_mode in modes[index + 1 :]
                for event in (nested_mode.sequence_keys or ())
            ]
            return " + ".join(["PREFIX", *keys])
    return ""


def redraw_tab_bar(_: int | None) -> None:
    global timer_id
    boss = get_boss()
    # The mode is global: refresh even a window that lost focus meanwhile.
    for tm in boss.os_window_map.values():
        tm.mark_tab_bar_dirty()
    # Timer callbacks can run after the render pass. Dirty flags alone do not
    # schedule another pass when the terminal has no output or cursor activity.
    wakeup_main_loop()
    if not prefix_status():
        if timer_id is not None:
            remove_timer(timer_id)
            timer_id = None


layout_symbols = {
    "grid": "􀕮 ",
    "stack": "􀂒 ",
    "fat": "􁒡 ",
    "tall": "􁒣 ",
    "splits": "􀏝 ",
}


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
    global active_tab_layout_name
    global active_tab_num_windows
    if tab.is_active:
        active_tab_layout_name = tab.layout_name
        active_tab_num_windows = tab.num_windows
    end = draw_tab_with_powerline(
        draw_data, screen, tab, before, max_title_length, index, is_last, extra_data
    )
    _draw_right_status(
        screen,
        is_last,
    )
    return end


def _draw_right_status(screen: Screen, is_last: bool) -> int:
    global timer_id
    if not is_last:
        return screen.cursor.x

    prefix_text = prefix_status()
    if prefix_text and timer_id is None:
        timer_id = add_timer(redraw_tab_bar, 0.05, True)
    cells = [
        # layout name
        (
            status_accent,
            screen.cursor.bg,
            " " + layout_symbols[active_tab_layout_name] + " ",
        ),
        (
            status_accent,
            screen.cursor.bg,
            active_tab_layout_name
            + (
                ""
                if active_tab_num_windows == 1
                else f" ({active_tab_num_windows} windows)"
            ),
        ),
    ]
    if prefix_text:
        cells.append((screen.cursor.bg, status_accent, f"  {prefix_text} "))

    # calculate leading spaces to separate tabs from right status
    right_status_length = 0
    for _, _, cell in cells:
        right_status_length += len(cell)
    leading_spaces = 0
    if opts.tab_bar_align == "center":
        leading_spaces = (
            math.ceil((screen.columns - screen.cursor.x) / 2) - right_status_length
        )
    elif opts.tab_bar_align == "left":
        leading_spaces = screen.columns - screen.cursor.x - right_status_length

    # draw leading spaces
    if leading_spaces > 0:
        screen.draw(" " * leading_spaces)

    # draw right status
    for fg, bg, cell in cells:
        screen.cursor.fg = fg
        screen.cursor.bg = bg
        screen.draw(cell)
    screen.cursor.fg = 0
    screen.cursor.bg = 0

    # update cursor position
    screen.cursor.x = max(screen.cursor.x, screen.columns - right_status_length)
    return screen.cursor.x
