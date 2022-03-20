import re
import subprocess

from subprocess import check_output

from libqtile import bar, widget
from libqtile.config import Screen
from libqtile.command import lazy

# from libqtile.log_utils import logger


def create_sep():
    return widget.Sep(foreground="707880", size_percent=60)


def run_shell_command(command):
    def inner():
        res = check_output(command.split()).decode("utf-8").strip()
        return res or " "

    return inner


class CapsNumScrollLockIndicator(widget.CapsNumLockIndicator):
    def get_indicators(self):
        """Return a list with the current state of the keys."""
        try:
            output = self.call_process(["xset", "q"])
        except subprocess.CalledProcessError as err:
            output = err.output
            return []
        indicators = re.findall(r"(?:Caps|Num|Scroll)\s+Lock:\s*(\w*)", output)
        return indicators

    def poll(self):
        """Poll content for the text box."""
        indicators = self.get_indicators()
        on, off = "ﰉ", "ﰊ"
        status = " ".join(indicators)
        status = status.replace("off", off).replace("on", on)[::-1]
        # reversed because it cames backwards somehow.
        return status


screens = [
    Screen(
        top=bar.Bar(
            [
                # widget.CurrentLayout(),
                widget.GroupBox(
                    active="62AEEF",  # Active group font colour
                    block_highlight_text_color="62AEFF",  # Selected group font colour
                    disable_drag=True,  # Disable dragging and dropping of group names on widget
                    font="Iosevka Nerd Font",
                    fontsize=20,
                    foreground="ff0000",  # Foreground colour
                    highlight_color=[
                        "373B41",
                        # "282828",
                    ],  # Active group highlight color when using 'line' highlight method.
                    highlight_method="line",  # Method of highlighting ('border', 'block', 'text', or 'line')Uses *_border color settings
                    inactive="707880",  # Inactive group font colour
                    invert_mouse_wheel=True,  # Whether to invert mouse wheel group movement
                    padding_x=8,  # X Padding. Overrides 'padding' if set
                ),
                widget.Prompt(),
                create_sep(),
                widget.WindowName(),
                widget.Chord(
                    chords_colors={
                        "launch": ("#ff0000", "#ffffff"),
                    },
                    name_transform=lambda name: name.upper(),
                ),
                widget.GenPollText(
                    func=run_shell_command("wgd"),
                    fontsize=23,
                    font="Iosevka Nerd Font",
                    foreground="62AEEF",
                    fmt=" {}",
                    update_interval=1,
                    mouse_callbacks={"Button1": lazy.spawn("wgd --toggle")},
                ),
                create_sep(),
                widget.GenPollText(
                    func=run_shell_command("rofi-bluetooth --status"),
                    fontsize=18,
                    font="Iosevka Nerd Font",
                    foreground="62AEEF",
                    update_interval=1,
                    mouse_callbacks={"Button1": lazy.spawn("rofi-bluetooth")},
                ),
                create_sep(),
                widget.PulseVolume(
                    emoji=True,
                    limit_max_volume=True,
                    step=4,
                    update_interval=0.1,
                    fmt='<span foreground="#62AEEF">VOL</span> {}',
                ),
                create_sep(),
                widget.KeyboardLayout(
                    configured_keyboards=["us cdhpt", "us cdhisopt"],
                    font="Iosevka Nerd Font Mono",
                    fontsize=23,
                    display_map={"us cdhpt": "", "us cdhisopt": ""},
                    foreground="62AEFF",
                ),
                CapsNumScrollLockIndicator(update_interval=0.5, foreground="62AEFF"),
                create_sep(),
                widget.WidgetBox(
                    widgets=[
                        widget.DF(
                            visible_on_warn=False,
                            format='<span foreground="#62AEEF">{p}</span> {r:.0f}%',
                        ),
                        create_sep(),
                        widget.Memory(
                            fmt='<span foreground="#62AEEF">RAM</span> {}',
                            format="{MemPercent: .0f}%",
                        ),
                        create_sep(),
                        widget.CPU(
                            format="{load_percent: .0f}%",
                            fmt='<span foreground="#62AEEF">CPU</span> {}',
                        ),
                        create_sep(),
                    ],
                    text_closed="[S<]",
                    text_open="[S>]",
                    foreground="62AEEF",
                    close_button_location="right",
                ),
                widget.WidgetBox(
                    widgets=[
                        widget.Net(interface=["enp3s0"]),
                        widget.Wlan(format="{essid} {percent:2.0%}"),
                        create_sep(),
                    ],
                    text_closed="[N<]",
                    text_open="[N>]",
                    foreground="62AEEF",
                    close_button_location="right",
                ),
                widget.Battery(format="{char} {percent:2.0%} {hour:d}:{min:02d}"),
                widget.Clock(format="%Y-%m-%d %a %I:%M %p"),
                widget.Systray(),
            ],
            size=30,
            background="#282A2E",
            border_width=[0, 0, 0, 0],
            margin=[4, 4, 4, 4],
            border_color=[
                "000000",
                "000000",
                "000000",
                "000000",
            ],
            opacity=0.95,
        ),
    ),
]
