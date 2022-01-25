import os
import subprocess

from libqtile import hook


@hook.subscribe.startup
def autostart():
    subprocess.call([os.path.expanduser('~/.config/qtile/autostart.sh')])
