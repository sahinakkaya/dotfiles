"""Reveal the already-listening guide once its display delay expires."""

from kittens.tui.handler import result_handler


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, data, target_window_id, boss):
    overlay = boss.window_id_map.get(target_window_id)
    if overlay is None:
        return
    tab = overlay.tabref()
    if tab is not None:
        layout = tab.current_layout
        if getattr(layout, 'overlay', None) is overlay:
            layout.reveal()
