"""Compile keybindings.toml for Kitty's geninclude and the shortcut guide."""

from pathlib import Path
import math
import tomllib


SOURCE = Path(__file__).with_name('keybindings.toml')


def text(value, where):
    if not isinstance(value, str) or not value.strip() or '\n' in value or '\r' in value:
        raise ValueError(f'{where}: expected a nonempty, single-line string')
    return value


def fields(value, allowed, where):
    if not isinstance(value, dict):
        raise ValueError(f'{where}: expected a table')
    unknown = value.keys() - set(allowed.split())
    if unknown:
        raise ValueError(f'{where}: unknown fields: {", ".join(sorted(unknown))}')


def load_bindings(path=SOURCE):
    with Path(path).open('rb') as source:
        data = tomllib.load(source)
    fields(data, 'version settings aliases modes prefixes groups mouse', 'keybindings')
    if type(data.get('version')) is not int or data['version'] != 1:
        raise ValueError('keybindings: version must be 1')
    for section in ('aliases', 'prefixes'):
        if not isinstance(data.get(section, {}), dict):
            raise ValueError(f'{section}: expected a table')
    for section in ('modes', 'groups', 'mouse'):
        if not isinstance(data.get(section, []), list):
            raise ValueError(f'{section}: expected an array of tables')
    settings = data.get('settings', {})
    fields(settings, 'kitty_mod map_timeout clear_all_shortcuts show_delay', 'settings')
    show_delay = settings.get('show_delay', 0.35)
    if type(show_delay) not in (float, int) or not math.isfinite(show_delay) or show_delay < 0:
        raise ValueError('settings.show_delay: expected a finite nonnegative number')
    text(settings.get('kitty_mod'), 'settings.kitty_mod')
    timeout = settings.get('map_timeout')
    if type(timeout) not in (float, int) or timeout < 0:
        raise ValueError('settings.map_timeout: expected a nonnegative number')
    if type(settings.get('clear_all_shortcuts')) is not bool:
        raise ValueError('settings.clear_all_shortcuts: expected a boolean')
    for name, action in data.get('aliases', {}).items():
        text(name, 'alias name')
        if any(c.isspace() for c in name):
            raise ValueError('alias names cannot contain whitespace')
        text(action, f'alias {name}')
    modes = {''}
    for mode in data.get('modes', []):
        fields(mode, 'name key timeout', 'mode')
        name = text(mode.get('name'), 'mode.name')
        if name in modes or any(c.isspace() for c in name):
            raise ValueError(f'invalid or duplicate mode: {name}')
        modes.add(name)
        text(mode.get('key'), f'mode {name}.key')
        timeout = mode.get('timeout', 0)
        if type(timeout) not in (float, int) or timeout < 0:
            raise ValueError(f'mode {name}.timeout: expected a nonnegative number')
    for prefix, name in data.get('prefixes', {}).items():
        text(prefix, 'prefix key sequence')
        text(name, f'prefix {prefix}')
    seen = set()
    for group in data.get('groups', []):
        fields(group, 'name mode actions', 'group')
        group_name = text(group.get('name'), 'group.name')
        mode = group.get('mode', '')
        if mode not in modes:
            raise ValueError(f'{group_name}: unknown mode {mode}')
        if not isinstance(group.get('actions'), list) or not group['actions']:
            raise ValueError(f'{group_name}: expected at least one action')
        for action in group['actions']:
            fields(action, 'name keys_label bindings', group_name)
            name = text(action.get('name'), f'{group_name}.action.name')
            if 'keys_label' in action:
                text(action['keys_label'], f'{name}.keys_label')
            if not isinstance(action.get('bindings'), list) or not action['bindings']:
                raise ValueError(f'{name}: expected at least one binding')
            for binding in action['bindings']:
                fields(binding, 'keys label action show repeat_timeout', name)
                if type(binding.get('show', True)) is not bool:
                    raise ValueError(f'{name}.show: expected a boolean')
                repeat_timeout = binding.get('repeat_timeout', 0)
                if type(repeat_timeout) not in (int, float) or not math.isfinite(repeat_timeout) or repeat_timeout < 0:
                    raise ValueError(f'{name}.repeat_timeout: expected a finite nonnegative number')
                text(binding.get('action'), f'{name}.action')
                if 'label' in binding:
                    text(binding['label'], f'{name}.label')
                keys = binding.get('keys')
                if not isinstance(keys, list) or not keys:
                    raise ValueError(f'{name}.keys: expected a nonempty list')
                for key in keys:
                    text(key, f'{name}.key')
                    if any(c.isspace() for c in key) or any(not part for part in key.split('>')):
                        raise ValueError(f'{name}: invalid key sequence {key!r}')
                    identity = mode, key
                    if identity in seen:
                        raise ValueError(f'duplicate binding: {mode or "global"} {key}')
                    seen.add(identity)
    for mouse in data.get('mouse', []):
        fields(mouse, 'name gesture action', 'mouse')
        for key in ('name', 'gesture', 'action'):
            text(mouse.get(key), f'mouse.{key}')
    return data


def render_config(data):
    settings = data['settings']
    lines = [f'kitty_mod {settings["kitty_mod"]}',
             f'map_timeout {settings["map_timeout"]}',
             'clear_all_shortcuts ' + ('yes' if settings['clear_all_shortcuts'] else 'no')]
    for name, action in data.get('aliases', {}).items():
        lines.append(f'action_alias {name} {action}')
    for mode in data.get('modes', []):
        lines.append(f'map --new-mode {mode["name"]} --timeout {mode.get("timeout", 0)} {mode["key"]}')
    for group in data.get('groups', []):
        mode = group.get('mode', '')
        option = f'--mode {mode} ' if mode else ''
        for action in group['actions']:
            for binding in action['bindings']:
                for key in binding['keys']:
                    lines.append(f'map {option}{key} {binding["action"]}')
    for mouse in data.get('mouse', []):
        lines.append(f'mouse_map {mouse["gesture"]} {mouse["action"]}')
    return '\n'.join(lines) + '\n'


def guide_metadata(data, mode, kitty_mod):
    # Canonicalize with the same parser and modifier resolution Kitty uses.
    from kitty.options.utils import parse_shortcut
    from kitty.types import human_repr_of_single_key

    def canonical(sequence):
        return tuple(human_repr_of_single_key(parse_shortcut(key).resolve_kitty_mod(kitty_mod), kitty_mod)
                     for key in sequence.split('>'))

    metadata = {}
    for gi, group in enumerate(data.get('groups', [])):
        if group.get('mode', '') != mode:
            continue
        for ai, action in enumerate(group['actions']):
            for binding in action['bindings']:
                for key in binding['keys']:
                    metadata[canonical(key), binding['action']] = {
                        'id': f'{gi}:{ai}', 'group': group['name'],
                        'name': action['name'], 'label': binding.get('label', ''),
                        'keys_label': action.get('keys_label', ''),
                        'show': binding.get('show', True),
                        'repeat_timeout': binding.get('repeat_timeout', 0),
                    }
    prefixes = {'>'.join(canonical(key)): name for key, name in data.get('prefixes', {}).items()}
    return metadata, prefixes


if __name__ == '__main__':
    print(render_config(load_bindings()), end='')
