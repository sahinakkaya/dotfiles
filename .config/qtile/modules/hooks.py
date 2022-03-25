import subprocess
import os

from libqtile import hook


@hook.subscribe.startup
def autostart():
    subprocess.call(["autostart.sh"])


@hook.subscribe.client_managed
def show_window(window):
    window.group.cmd_toscreen()


@hook.subscribe.client_managed
@hook.subscribe.client_urgent_hint_changed
@hook.subscribe.client_killed
@hook.subscribe.setgroup
@hook.subscribe.group_window_add
@hook.subscribe.current_screen_change
@hook.subscribe.changegroup
def hook_response(*args, **kwargs):
    file = os.path.expanduser('~/.cache/workspaces')
    with open(file, 'a') as f:
        print('workspace changed', file=f)
