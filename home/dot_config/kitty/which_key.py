"""Open the prefix guide, then replay selections through Kitty's real mappings."""

import json
from pathlib import Path

from kittens.tui.handler import result_handler
from kitty.constants import config_dir
from kitty.fast_data_types import add_timer, get_options, viewport_for_window
from kitty.key_encoding import KeyEvent, EventType
from kitty.options.utils import KeyboardMode
from kitty.types import WindowGeometry, human_repr_of_single_key
from keybindings import guide_metadata, load_bindings


class GuideLayout:
    """Temporarily give only the guide the entire OS window's content area.

    Keep the original layout object and pane geometries intact. Delegating its
    metadata also keeps tab status and layout history unchanged.
    """

    def __init__(self, original, overlay, tab=None, visibility=None, visible=True):
        self.original = original
        self.overlay = overlay
        self.tab = tab
        self.visibility = visibility or {}
        self.visible = visible

    @property
    def only_active_window_visible(self):
        return True if self.visible else self.original.only_active_window_visible

    @property
    def must_draw_borders(self):
        return False if self.visible else self.original.must_draw_borders

    @property
    def needs_window_borders(self):
        return False if self.visible else self.original.needs_window_borders

    @property
    def blank_rects(self):
        return () if self.visible else self.original.blank_rects

    def reveal(self):
        if not self.visible:
            self.visible = True
            self.tab.relayout()
            self.overlay.refresh()

    def __getattr__(self, name):
        return getattr(self.original, name)

    def update_visibility(self, windows):
        for window in windows:
            visible = window is self.overlay if self.visible else self.visibility.get(window.id, False)
            window.set_visible_in_layout(visible)

    def get_minimal_borders(self, windows):
        return () if self.visible else self.original.get_minimal_borders(windows)

    def __call__(self, windows):
        self.update_visibility(windows)
        if not self.visible:
            return
        central, _, _, _, cell_width, cell_height = viewport_for_window(self.overlay.os_window_id)
        columns = max(1, central.width // cell_width)
        rows = max(1, central.height // cell_height)
        self.overlay.show_title_bar = False
        self.overlay.set_geometry(WindowGeometry(
            central.left, central.top,
            central.left + columns * cell_width,
            central.top + rows * cell_height, columns, rows,
        ))


def snapshot_panes(tab, os_window_id):
    central, _, _, _, cell_width, cell_height = viewport_for_window(os_window_id)
    regions = []
    for pane in tab:
        if pane.is_visible_in_layout:
            regions.append({
                'column': max(0, (pane.geometry.left - central.left) // cell_width),
                'row': max(0, (pane.geometry.top - central.top) // cell_height),
                'lines': [pane.screen.line(row).as_ansi()
                          for row in range(pane.screen.lines)],
            })
    return regions


def main(args):
    pass


def refresh_prefix_bindings(boss):
    """TOML is a geninclude input, so editing it may not trigger a reload."""
    opts = get_options()
    expected, _ = guide_metadata(load_bindings(), 'kitty_prefix', opts.kitty_mod)
    mode = boss.mappings.keyboard_modes.get('kitty_prefix')
    actual = set()
    if mode is not None:
        for definitions in mode.keymap.values():
            for definition in definitions:
                keys = tuple(human_repr_of_single_key(key, opts.kitty_mod)
                             for key in definition.full_key_sequence_to_trigger)
                actual.add((keys, definition.definition))
    if actual != set(expected):
        boss.load_config_file()


def normalize_repeat_permissions(boss, previous_peers):
    # Kitty 0.47.1 passes the kitten's string permission directly to a checker
    # expecting an iterable of command names, which otherwise checks letters.
    # Correct only channels created for this guide, retaining action-only access.
    for peer in boss.peer_data_map.keys() - previous_peers:
        passwords = boss.peer_data_map[peer]
        if passwords:
            for password, permissions in passwords.items():
                if permissions == 'action':
                    passwords[password] = ('action',)


def show_guide(boss, target_window_id):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    tab = window.tabref()
    if tab is None:
        return
    original_layout = tab.current_layout
    visibility = {pane.id: pane.is_visible_in_layout for pane in tab}
    background = snapshot_panes(tab, window.os_window_id)
    guide_layout = None
    mappings = boss.mappings
    mode = mappings.keyboard_modes['kitty_prefix']
    opts = get_options()
    config = load_bindings()
    show_delay = config['settings'].get('show_delay', 0.35)
    metadata, prefixes = guide_metadata(config, 'kitty_prefix', opts.kitty_mod)
    entries = []
    for definitions in mode.keymap.values():
        for definition in definitions:
            keys = [human_repr_of_single_key(k, opts.kitty_mod)
                    for k in definition.full_key_sequence_to_trigger]
            entries.append({
                'keys': keys,
                'action': definition.definition,
                **metadata.get((tuple(keys), definition.definition), {}),
            })

    # Global modal mappings would otherwise intercept the overlay's keys.
    saved_modes = mappings.keyboard_mode_stack[:]
    mappings.clear_keyboard_modes()
    input_mode = KeyboardMode('__which_key_input__')
    input_mode.on_unknown = 'passthrough'
    mappings._push_keyboard_mode(input_mode)

    def cleanup(wid, boss):
        mappings.pop_keyboard_mode_if_is(input_mode.name)
        if guide_layout is not None and tab.current_layout is guide_layout:
            tab.current_layout = original_layout
            tab.relayout()

    def finish(data, wid, boss):
        if not data or wid not in boss.window_id_map:
            return

        def replay(_):
            if wid not in boss.window_id_map:
                return
            for mode in saved_modes:
                mappings._push_keyboard_mode(mode)
            for raw in data:
                raw['type'] = EventType(raw['type'])
                mappings.dispatch_possible_special_key(KeyEvent(**raw).as_window_system_event())
            if mappings.current_keyboard_mode_name == 'kitty_prefix':
                active = boss.active_window
                if active is not None:
                    show_guide(boss, active.id)

        # on_close runs before overlay removal: defer actions until focus returns
        # to the original pane, so close/resize/paste cannot target the guide.
        add_timer(replay, 0.01, False)

    try:
        previous_peers = set(boss.peer_data_map)
        overlay = boss.run_kitten_with_metadata(
            str(Path(config_dir) / 'which_key_ui.py'),
            input_data=json.dumps({
                'entries': entries,
                'background': background,
                'prefixes': prefixes,
                'target_window_id': target_window_id,
                'show_delay': show_delay,
            }), window=window, custom_callback=finish,
            action_on_removal=cleanup,
        )
        normalize_repeat_permissions(boss, previous_peers)
        if overlay is None:
            cleanup(target_window_id, boss)
            for mode in saved_modes:
                mappings._push_keyboard_mode(mode)
        else:
            guide_layout = GuideLayout(original_layout, overlay, tab, visibility, visible=show_delay == 0)
            tab.current_layout = guide_layout
            tab.relayout()
    except Exception:
        cleanup(target_window_id, boss)
        for mode in saved_modes:
            mappings._push_keyboard_mode(mode)
        raise


@result_handler(no_ui=True)
def handle_result(args, data, target_window_id, boss):
    refresh_prefix_bindings(boss)
    boss.mappings.push_keyboard_mode('kitty_prefix')
    show_guide(boss, target_window_id)
