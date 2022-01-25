from libqtile.config import Group, Key, Match
from libqtile.lazy import lazy

from .keys import keys, mod

groups = [Group(i) for i in "123456789"]

symbols = ['semicolon', 'comma', 'period', 'p', 'y', 'equal', 'g', 'c', 'r', 'percent']

for i, j in zip(groups, symbols):
    keys.extend([
        Key([mod], j, lazy.group[i.name].toscreen(),
            desc="Switch to group {}".format(i.name)),

        Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            desc="move focused window to group {}".format(i.name)),

        # Use below if you prefer to switch to that group.
        # Key([mod, "shift"], j, lazy.window.togroup(i.name, switch_group=True),
        #     desc="Switch to & move focused window to group {}".format(i.name)),
    ])
