import os

from libqtile.config import Key, KeyChord
from libqtile.lazy import lazy

mod = "mod4"
terminal = "st"
# terminal = "xfce4-terminal"
home = os.path.expanduser

keys = [
       # '`': 'grave',
       # '-': 'minus',
       # '=': 'equal',
       # '[': 'bracketleft',
       # ']': 'bracketright',
       # '\\': 'backslash',
       # ';': 'semicolon',
       # '\'': 'quote',
       # ',': 'comma',
       # '.': 'dot',
       Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
       Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
       Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
       Key([mod], "k", lazy.layout.up(), desc="Move focus up"),

       Key([mod], "Tab", lazy.screen.toggle_group(),
           desc="Toggle back and forth between latest groups"),
       Key([mod], "d", lazy.spawn("rofi -show combi"), desc="spawn rofi"),

       # Move windows between left/right columns or move up/down in current
       # stack. Moving out of range in Columns layout will create new column.
       Key([mod, "shift"], "h",
           lazy.layout.shuffle_left(), desc="Move window to the left"),
       Key([mod, "shift"], "l",
           lazy.layout.shuffle_right(), desc="Move window to the right"),
       Key([mod, "shift"], "j",
           lazy.layout.shuffle_down(), desc="Move window down"),
       Key([mod, "shift"], "k",
           lazy.layout.shuffle_up(), desc="Move window up"),

       # Grow windows. If current window is on the edge of screen and direction
       # will be to screen edge - window would shrink.
       Key([mod, "control"], "h",
           lazy.layout.grow_left(), desc="Grow window to the left"),
       Key([mod, "control"], "l",
           lazy.layout.grow_right(), desc="Grow window to the right"),
       Key([mod, "control"], "j",
           lazy.layout.grow_down(), desc="Grow window down"),
       Key([mod, "control"], "k",
           lazy.layout.grow_up(), desc="Grow window up"),
       # KeyChord([mod], "w", [
       #        Key([], "g", lazy.layout.grow()),
       #        Key([], "s", lazy.layout.shrink()),
       #        Key([], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
       #        Key([], "m", lazy.layout.maximize())],
       #        mode="Windows"
       #    ),
       Key([mod], "f",
           lazy.window.toggle_fullscreen(), desc='Toggle fullscreen'),
       Key([mod, "shift"], "f",
           lazy.window.toggle_floating(), desc='Toggle floating'),

       # Toggle between split and unsplit sides of stack.
       # Split = all windows displayed
       # Unsplit = 1 window displayed, like Max layout, but still with
       # multiple stack panes
       Key([mod, "shift"], "Return",
           lazy.layout.toggle_split(),
           desc="Toggle between split and unsplit sides of stack"),
       Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),

       # Toggle between different layouts as defined below
       Key([mod], "space", lazy.next_layout(), desc="Toggle between layouts"),
       Key([mod, 'shift'], "space",
           lazy.spawn("chlayout"), desc="Next keyboard layout."),
       Key([mod], "comma",
           lazy.screen.prev_group(), desc="Move to the group on the left"),
       Key([mod], "period",
           lazy.screen.next_group(), desc="Move to the group on the right"),
       Key([mod], "q",
           lazy.window.kill(), desc="Kill focused window"),
       Key([mod, "shift", "control"], "h",
           lazy.layout.swap_column_left()),
       Key([mod, "shift", "control"], "l", lazy.layout.swap_column_right()),
       # Key([mod, "shift"], "space", lazy.layout.flip()),
       Key([mod, "control"], "r", lazy.restart(), desc="Restart Qtile"),
       Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
       Key([mod, "control"], "n",
           lazy.spawn("lock-screen"), desc="Lock screen"),
       Key([mod, "control"], "s",
           lazy.spawn("toggle-screenkey"), desc="Show keys on screen"),
       Key([mod, "shift"], "d",
           lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
       Key([mod], "p", lazy.spawn("passmenu"), desc="Spawn passmenu"),

       # Key([mod, "shift"], "e", lazy.spawn("menu_powermenu"), desc="Spawn powermenu using rofi"),

       # Key([mod], "n", lazy.spawn(home("~/Desktop/GitRepositories/networkmanager-dmenu/networkmanager_dmenu")), desc="Launch network manager"),
        # Key([mod], "i", lazy.spawn("sxiv " + home("~/Pictures/keyboard-layout.jpg")), desc="Show current keyboard layout"),

        Key([mod], "b", lazy.spawn('rofi-bluetooth'),
            desc="Manage bluetooth devices"),

        Key([mod], "v", lazy.spawn('polybar-wireguard --toggle'),
            desc="Manage VPN connections"),

        # Key([mod], "x", lazy.spawn(home("~/scripts/kill-process.sh")),
        #     desc="Kill processes using rofi"),

        # == audio

        Key([], "XF86AudioRaiseVolume",
            lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")),
        Key([], "XF86AudioLowerVolume",
            lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")),
        Key([], "XF86AudioMute",
            lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")),
        Key([], "XF86AudioMicMute",
            lazy.spawn("pactl set-source-mute @DEFAULT_SOURCE@ toggle")),


        # == backlight
        Key([], "XF86MonBrightnessUp",
            lazy.spawn("xbacklight -inc 5")),
        Key([], "XF86MonBrightnessDown",
            lazy.spawn("xbacklight -dec 5")),

        Key([], "Print",
            lazy.spawn("flameshot gui")),

        Key(["shift"], "Print",
            lazy.spawn("flameshot full")),

        Key(["control"], "Print",
            lazy.spawn("flameshot full")),

        Key([], 'F12', lazy.group['scratchpad'].dropdown_toggle('term')),

        Key([], "XF86KbdBrightnessUp",
            lazy.spawn("keyboard_backlight.sh inc")),
        Key([], "XF86KbdBrightnessDown",
            lazy.spawn("keyboard_backlight.sh dec")),


        Key([], "XF86TouchpadToggle",
            lazy.spawn("toggle-touchpad.sh")),
]
