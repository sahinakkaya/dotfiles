"""Execute a repeatable action without consuming the guide's keyboard mode."""

from kittens.tui.handler import result_handler


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, data, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    mappings = boss.mappings
    saved_modes = mappings.keyboard_mode_stack[:]
    # A binding may include pop_keyboard_mode (including through an alias).
    # Let it execute without popping the overlay's input mode.
    mappings.clear_keyboard_modes()
    try:
        boss.combine(args[1], window_for_dispatch=window, raise_error=True)
    finally:
        mappings.clear_keyboard_modes()
        for mode in saved_modes:
            mappings._push_keyboard_mode(mode)
