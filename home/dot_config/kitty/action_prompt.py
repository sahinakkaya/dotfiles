"""Ask for arguments to a Kitty action, then run it in the original pane."""

from kittens.tui.handler import result_handler
from kitty.actions import get_all_actions


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, data, target_window_id, boss):
    name = args[1]
    actions = {action.name: action for group in get_all_actions().values() for action in group}
    action = actions.get(name)
    window = boss.window_id_map.get(target_window_id)
    if action is None or window is None:
        return
    # no_op is a mapping directive rather than an executable action. Selecting
    # it should simply close the guide without leaking the selected key.
    if name == 'no_op':
        return

    def execute(command):
        command = command.strip()
        target = boss.window_id_map.get(target_window_id)
        if not command or target is None:
            return
        if command.split()[0] != name:
            boss.show_error('Invalid action', f'Expected a command starting with {name}.')
            return
        try:
            boss.combine(command, window_for_dispatch=target, raise_error=True)
        except Exception as error:
            boss.show_error(f'Could not run {name}', str(error))

    message = f'{name}\n\n{action.short_help}'
    if action.long_help:
        message += '\n\n' + action.long_help
    message += '\n\nEnter the Kitty action and its arguments. Escape cancels.'
    boss.get_line(message, execute, window=window, initial_value=name + ' ',
                  window_title='Kitty action: ' + name)
