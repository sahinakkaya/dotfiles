"""Use native mappings until the user pauses long enough to need the guide."""

from time import monotonic

from kitty.fast_data_types import GLFW_RELEASE, add_timer, is_modifier_key, remove_timer
from kitty.key_encoding import (
    ALT, CTRL, HYPER, META, SHIFT, SUPER, KeyEvent,
    get_name_to_functional_number_map, parse_shortcut,
)
from kitty.keys import get_shortcut
from kitty.types import human_repr_of_single_key


def event_for_key(spec):
    mods, key = parse_shortcut(spec)
    return KeyEvent(key=key, mods=mods, shift=bool(mods & SHIFT), alt=bool(mods & ALT),
                    ctrl=bool(mods & CTRL), super=bool(mods & SUPER),
                    hyper=bool(mods & HYPER), meta=bool(mods & META))._asdict()


class PendingGuide:
    def __init__(self, boss, target_window_id, delay, metadata, kitty_mod, show):
        self.boss = boss
        self.mappings = boss.mappings
        self.root = self.mappings.keyboard_mode_stack[-1]
        self.target_window_id = target_window_id
        self.metadata = metadata
        self.kitty_mod = kitty_mod
        self.show = show
        self.path = []
        self.events = []
        self.display_timer = None
        self.repeat_timer = None
        self.repeat_deadline = 0
        self.repeat_timeout = 0
        self.stopped = False
        self.original_dispatch = self.mappings.dispatch_possible_special_key
        self.previous_dispatch = self.mappings.__dict__.get('dispatch_possible_special_key')
        self.handler = self.dispatch
        self.mappings.dispatch_possible_special_key = self.handler
        self.display_timer = add_timer(self.reveal, delay, False)

    def active(self):
        stack = self.mappings.keyboard_mode_stack
        return (self.root in stack and
                all(mode.sequence_keys is not None for mode in stack[stack.index(self.root) + 1:]))

    def cancel_repeat(self):
        if self.repeat_timer is not None:
            remove_timer(self.repeat_timer)
            self.repeat_timer = None
        self.repeat_deadline = self.repeat_timeout = 0

    def stop(self):
        if self.stopped:
            return
        self.stopped = True
        for timer in (self.display_timer, self.repeat_timer):
            if timer is not None:
                remove_timer(timer)
        self.display_timer = self.repeat_timer = None
        if self.mappings.__dict__.get('dispatch_possible_special_key') is self.handler:
            if self.previous_dispatch is None:
                del self.mappings.dispatch_possible_special_key
            else:
                self.mappings.dispatch_possible_special_key = self.previous_dispatch
        if getattr(self.boss, '_which_key_pending', None) is self:
            self.boss._which_key_pending = None

    def expire_repeat(self, _):
        self.repeat_timer = None
        if self.active():
            self.mappings.clear_keyboard_modes()
        self.stop()

    def reveal(self, _=None):
        self.display_timer = None
        if self.stopped:
            return
        if not self.active():
            self.stop()
            return
        initial = {'path': self.path[:], 'events': [event_for_key(key) for key in self.path],
                   'repeat_deadline': self.repeat_deadline, 'repeat_timeout': self.repeat_timeout}
        # The UI replays full sequences from the root, so do not retain a
        # half-completed native sequence beneath its own sequence state.
        while self.mappings.keyboard_mode_stack[-1] is not self.root:
            self.mappings.pop_keyboard_mode()
        window = self.boss.active_window
        target = window.id if window is not None else self.target_window_id
        self.stop()
        self.show(self.boss, target, initial_state=initial, display_delay=0)

    def dispatch(self, event):
        if self.stopped or not self.active():
            self.stop()
            return self.original_dispatch(event)
        if event.action == GLFW_RELEASE or is_modifier_key(event.key):
            return False
        names = get_name_to_functional_number_map()
        if event.key in (names['ESCAPE'], names['F18']):
            self.mappings.clear_keyboard_modes()
            self.stop()
            return True
        if event.key == names['BACKSPACE'] and self.path:
            self.cancel_repeat()
            events = self.events[:-1]
            self.path = self.path[:-1]
            self.events = events
            while self.mappings.keyboard_mode_stack[-1] is not self.root:
                self.mappings.pop_keyboard_mode()
            for previous in events:
                self.original_dispatch(previous)
            return True
        if event.key in (names['UP'], names['DOWN']):
            self.reveal()
            return self.original_dispatch(event)

        mode = self.mappings.keyboard_mode_stack[-1]
        definitions = get_shortcut(mode.keymap, event)
        selected = self.mappings.matching_key_actions(definitions) if definitions else []
        if not selected:
            # Match the guide's unknown-key behavior without forwarding a
            # partial prefix into the shell.
            self.mappings.clear_keyboard_modes()
            self.stop()
            return True
        definition = selected[0]
        key = next(key for key, definitions in mode.keymap.items()
                   if any(item is definition for item in definitions))
        key_name = human_repr_of_single_key(key, self.kitty_mod)
        leaf = not definition.is_sequence or not definition.rest
        full_path = self.path + [key_name]
        info = self.metadata.get((tuple(full_path), definition.definition), {})
        timeout = info.get('repeat_timeout', 0) if leaf else 0
        if not timeout:
            self.cancel_repeat()
        consumed = self.original_dispatch(event)

        if timeout:
            self.cancel_repeat()
            # Once an action has started repeating, remain unobtrusive until
            # its inactivity timeout exits the mode. In particular, this lets
            # a repeat timeout be longer than the guide's display delay.
            if self.display_timer is not None:
                remove_timer(self.display_timer)
                self.display_timer = None
            # Native dispatch removes a completed sequence mode. Restore its
            # submenu so subsequent i/d presses execute immediately as well.
            if self.root not in self.mappings.keyboard_mode_stack:
                self.mappings._push_keyboard_mode(self.root)
            if mode is not self.root and mode not in self.mappings.keyboard_mode_stack:
                self.mappings._push_keyboard_mode(mode)
            self.repeat_timeout = timeout
            self.repeat_deadline = monotonic() + timeout
            self.repeat_timer = add_timer(self.expire_repeat, timeout, False)
        elif leaf:
            self.path, self.events = [], []
        else:
            self.path.append(key_name)
            self.events.append(event)
        if not self.active():
            self.stop()
        return consumed
