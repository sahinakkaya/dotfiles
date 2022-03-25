from libqtile.config import Group, Key, Match, ScratchPad, DropDown
from libqtile.lazy import lazy

from .keys import keys, mod

groups = [Group(i) for i in "1234567890"]

browsers = [Match(wm_class=["firefox", "Google-chrome"])]
file_managers = [Match(wm_class="Thunar")]
video_players = [Match(wm_class=["streamlink-twitch-gui", "mpv"])]
groups = [
    Group("1"),
    Group("2", matches=[Match(wm_class="VirtualBox Manager")]),
    Group("3", matches=[Match(wm_class="Thunderbird")]),
    Group("4", matches=[Match(wm_class="st-256color")]),
    Group("5", matches=file_managers),
    Group("6", matches=[Match(wm_class="ModernDeck")]),
    Group("7", matches=browsers),
    Group("8", matches=video_players),
    Group("9"),
    Group("0", matches=[Match(wm_class="TelegramDesktop")]),
]
groups.append(
    ScratchPad(
        "scratchpad",
        [
            # define a drop down terminal.
            # it is placed in the upper third of screen by default.
            DropDown("term", "st", opacity=1.0)
        ],
    )
)

symbols = "arstgmneio"

for i, j in zip(groups, symbols):
    keys.extend(
        [
            Key(
                [mod],
                j,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            Key(
                [mod, "shift"],
                j,
                lazy.window.togroup(i.name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(i.name),
            ),
        ]
    )
