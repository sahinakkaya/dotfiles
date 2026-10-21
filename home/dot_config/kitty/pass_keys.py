import re

from kittens.tui.handler import result_handler
from kitty.key_encoding import KeyEvent, parse_shortcut

from relative_resize import relative_resize_window

VIM_ID = "n?vim"


def is_window_vim(window, vim_id=VIM_ID):
    fp = window.child.foreground_processes
    return any(
        re.search(vim_id, p["cmdline"][0] if len(p["cmdline"]) else "", re.I)
        for p in fp
    )


def encode_key_mapping(window, key_mapping):
    mods, key = parse_shortcut(key_mapping)
    event = KeyEvent(
        mods=mods,
        key=key,
        shift=bool(mods & 1),
        alt=bool(mods & 2),
        ctrl=bool(mods & 4),
        super=bool(mods & 8),
        hyper=bool(mods & 16),
        meta=bool(mods & 32),
    ).as_window_system_event()

    return window.encoded_key(event)


def main():
    pass


@result_handler(no_ui=True)
def handle_result(args, result, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    action = args[1]
    direction = args[2]
    key_mapping = args[3] if action == 'neighboring_window' else args[4]
    amount = int(args[3]) if action == 'relative_resize' else None
    vim_id_idx = 4 if action == 'neighboring_window' else 5
    vim_id = args[vim_id_idx] if len(args) > vim_id_idx else VIM_ID

    if window is None:
        return
    if is_window_vim(window, vim_id):
        for keymap in key_mapping.split(">"):
            encoded = encode_key_mapping(window, keymap)
            window.write_to_child(encoded)
    elif action == 'neighboring_window':
        boss.active_tab.neighboring_window(direction)
    elif action == 'relative_resize':
        relative_resize_window(direction, amount, target_window_id, boss)
