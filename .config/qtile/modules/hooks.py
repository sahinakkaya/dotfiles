import subprocess

from libqtile import hook
from libqtile.command.client import InteractiveCommandClient


@hook.subscribe.startup
def autostart():
    subprocess.call(['autostart.sh'])


@hook.subscribe.startup_complete
def focus_group():
    c = InteractiveCommandClient()
    c.group['4'].toscreen()


@hook.subscribe.client_managed
def show_window(window):
    window.group.cmd_toscreen()
