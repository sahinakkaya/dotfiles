"""Keyboard-driven, automatically generated prefix shortcut guide."""

import json
import os
import shlex
import sys

from kittens.tui.handler import Handler, kitten_ui, result_handler
from kittens.tui.loop import Loop
from kitty.fast_data_types import is_modifier_key
from kitty.key_encoding import get_name_to_functional_number_map


def action_label(action):
    action = action.replace('combine : pop_keyboard_mode : ', '')
    return action.replace('_', ' ')


def choices(entries, depth, prefixes=None):
    """Display the groups and named actions explicitly declared in TOML."""
    prefixes = prefixes or {}
    groups = {}
    submenus = {}
    hidden_actions = {entry.get('id', tuple(entry['keys'])) for entry in entries
                      if len(entry['keys']) == depth + 1 and not entry.get('show', True)}
    for entry in entries:
        group = entry.get('group', 'Other')
        key = entry['keys'][depth]
        if len(entry['keys']) > depth + 1:
            path = '>'.join(entry['keys'][:depth + 1])
            name = prefixes.get(path, group if group != 'Other' else 'More shortcuts')
            submenu = submenus.setdefault(key, {'name': name, 'next_keys': []})
            next_key = entry['keys'][depth + 1]
            if (entry.get('show', True) or len(entry['keys']) > depth + 2) and next_key not in submenu['next_keys']:
                submenu['next_keys'].append(next_key)
        else:
            if not entry.get('show', True):
                continue
            rows = groups.setdefault(group, {})
            # Only the top level combines explicitly shared TOML actions.
            # Submenus show every binding and alias separately.
            identity = (('binding', tuple(entry['keys']), entry['action']) if depth
                        else ('action', entry.get('id', tuple(entry['keys']))))
            row = rows.setdefault(identity, {
                'keys': [], 'name': entry.get('name', action_label(entry['action'])),
                'labels': [], 'keys_label': ('' if depth or identity[1] in hidden_actions
                                             else entry.get('keys_label', '')),
            })
            if key not in row['keys']:
                row['keys'].append(key)
            label = entry.get('label', '')
            if label and label not in row['labels']:
                row['labels'].append(label)
    result = []
    for group, rows in groups.items():
        for row in rows.values():
            keys = row['keys_label'] or '/'.join(row['keys'])
            label = row['name']
            if row['labels'] and (depth or len(row['labels']) > 1):
                label += ' (' + ' / '.join(row['labels']) + ')'
            result.append((keys, label))
    # Leaves precede subgroups. Collect shared prefixes across source groups
    # so each submenu still gets exactly one hint.
    for key, submenu in submenus.items():
        next_keys = '/'.join(submenu['next_keys'])
        preview = ' → ' + next_keys if next_keys else ''
        result.append((key, f'+ {submenu["name"]}{preview}'))
    return result


class Guide(Handler):
    def __init__(self, entries, background=(), prefixes=None, run_repeat=None,
                 show_delay=0, show_overlay=None):
        self.entries = entries
        self.background = background
        self.prefixes = prefixes or {}
        self.path = []
        self.events = []
        self.result = None
        self.page = 0
        self.run_repeat = run_repeat
        self.repeat_timer = None
        self.repeat_timeout = 0
        self.error = ''
        self.show_delay = show_delay
        self.show_overlay = show_overlay
        self.show_timer = None

    def cancel_repeat(self):
        if self.repeat_timer is not None:
            self.repeat_timer.cancel()
            self.repeat_timer = None
        self.repeat_timeout = 0

    def finalize(self):
        self.cancel_repeat()
        if self.show_timer is not None:
            self.show_timer.cancel()
            self.show_timer = None

    def expire_repeat(self):
        self.repeat_timer = None
        self.repeat_timeout = 0
        self.quit_loop(0)

    def current_entries(self):
        return [entry for entry in self.entries
                if entry['keys'][:len(self.path)] == self.path]

    def initialize(self):
        self.draw()
        if self.show_delay > 0:
            self.show_timer = self.asyncio_loop.call_later(self.show_delay, self.reveal)

    def reveal(self):
        self.show_timer = None
        if self.show_overlay is not None:
            self.show_overlay()

    def on_resize(self, screen_size):
        super().on_resize(screen_size)
        self.draw()

    def draw(self):
        width = max(1, self.screen_size.cols)
        height = min(self.screen_size.rows, max(7, self.screen_size.rows // 3))
        top = self.screen_size.rows - height
        columns = max(1, min(3, width // 48))
        cell_width = width // columns
        rows = max(1, height - 4)
        capacity = rows * columns
        entries = self.current_entries()
        depth = len(self.path)
        submenu_keys = {entry['keys'][depth] for entry in entries if len(entry['keys']) > depth + 1}
        items = choices(entries, depth, self.prefixes)
        pages = max(1, (len(items) + capacity - 1) // capacity)
        self.page = min(self.page, pages - 1)
        page = items[self.page * capacity:(self.page + 1) * capacity]
        title = ' PREFIX' + ''.join(' + ' + key for key in self.path)
        lines = [title[:width], '─' * width]
        for row in range(rows):
            cells = []
            for column in range(columns):
                index = column * rows + row
                text = ''
                is_submenu = False
                if index < len(page):
                    key, label = page[index]
                    text = f' {key:>9}  {label}' if key else f' {label}'
                    is_submenu = key in submenu_keys
                # Fit visible text before adding escapes; slicing ANSI-styled
                # rows can truncate a sequence or leak italics into other cells.
                cell = text[:cell_width - 1].ljust(cell_width)
                if is_submenu:
                    cell = '\x1b[3;34m' + cell + '\x1b[0m'
                cells.append(cell)
            lines.append(''.join(cells))
        footer = f' Esc/F18 close · Backspace back · ↑/↓ pages · {self.page + 1}/{pages}'
        if self.repeat_timeout:
            footer = f' Repeat · {self.repeat_timeout:g}s inactivity timeout · Esc/F18 close'
        if self.error:
            footer = ' ' + self.error
        lines.extend(['─' * width, footer[:width]])

        # The guide spans the OS window. Preserve snapshots of all visible
        # panes above the panel, without resizing their running applications.
        output = ['\x1b[?25l\x1b[?7l\x1b[0m\x1b[2J']
        for region in self.background:
            column = region['column']
            if column >= width:
                continue
            for offset, line in enumerate(region['lines']):
                row = region['row'] + offset
                if row >= top:
                    break
                output.append(f'\x1b[{row + 1};{column + 1}H\x1b[0m' + line)
        for row, line in enumerate(lines[:height]):
            # The overlay inherits the pane's color profile. Default colors
            # and palette blue follow both light/dark themes and live updates.
            output.append(f'\x1b[{top + row + 1};1H\x1b[0m\x1b[2K')
            output.append('\x1b[1;34m' if row < 2 else '\x1b[39m')
            output.append(line)
        output.append('\x1b[0m')
        self.write(''.join(output))

    def perform_default_key_action(self, event):
        return False

    def on_key_event(self, event, in_bracketed_paste=False):
        if event.is_release or in_bracketed_paste:
            return
        # The extended keyboard protocol reports bare modifier presses too.
        # Wait for the actual shortcut, just as Kitty's native mappings do.
        if is_modifier_key(get_name_to_functional_number_map().get(event.key, 0)):
            return
        if event.matches('escape') or event.matches('f18'):
            self.quit_loop(0)
            return
        if event.matches('backspace') and self.path:
            self.cancel_repeat()
            self.path.pop()
            self.events.pop()
            self.page = 0
            self.draw()
            return
        if event.matches('down') or event.matches('up'):
            self.page = max(0, self.page + (1 if event.matches('down') else -1))
            self.draw()
            return
        depth = len(self.path)
        entries = self.current_entries()
        matched = [entry for entry in entries if event.matches(entry['keys'][depth])]
        if not matched:
            # An unknown key exits, just as the original prefix mode does.
            self.quit_loop(0)
            return
        leaf = next((entry for entry in matched if len(entry['keys']) == depth + 1), None)
        if leaf is not None and leaf.get('repeat_timeout', 0) > 0 and self.run_repeat is not None:
            self.cancel_repeat()
            try:
                self.run_repeat(leaf['action'])
            except Exception as error:
                self.error = f'Action failed: {error}'
                self.draw()
                return
            self.error = ''
            self.repeat_timeout = leaf['repeat_timeout']
            self.repeat_timer = self.asyncio_loop.call_later(self.repeat_timeout, self.expire_repeat)
            # Keep only the prefix events/path. The command already ran, so
            # repeating must not replay it again when the overlay closes.
            self.draw()
            return
        self.cancel_repeat()
        self.events.append(event._asdict())
        self.path.append(matched[0]['keys'][depth])
        if any(len(entry['keys']) == depth + 1 for entry in matched):
            self.result = self.events
            self.quit_loop(0)
        else:
            self.page = 0
            self.draw()


@kitten_ui(allow_remote_control=True, remote_control_password='action')
def main(args):
    data = json.loads(sys.stdin.read())

    def remote_action(request, target):
        result = main.remote_control(
            ['action', '--match', f'id:{target}', request],
            capture_output=True, text=True,
        )
        if result.returncode:
            raise RuntimeError(result.stderr.strip() or 'Kitty rejected the action')

    def run_repeat(command):
        request = 'kitten repeat_action.py ' + shlex.quote(command)
        remote_action(request, data['target_window_id'])

    guide = Guide(data['entries'], data['background'], data.get('prefixes'), run_repeat,
                  show_delay=data.get('show_delay', 0),
                  show_overlay=lambda: remote_action('kitten reveal_guide.py', os.environ['KITTY_WINDOW_ID']))
    Loop().loop(guide)
    return guide.result


@result_handler()
def handle_result(args, data, target_window_id, boss):
    pass
