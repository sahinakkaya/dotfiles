from libqtile import layout
from libqtile.config import Match

# default = {
#     "border_width": 2,
#     "margin": 8,
#     "border_focus": "#5294e2",
#     "border_normal": "#2c5380"}
layouts = [
    # layout.MonadTall(margin=8, border_focus='#5294e2',
    #                  border_normal='#2c5380'),
    layout.Columns(margin=8, border_focus_stack="#d75f5f"),
    layout.Max(),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(wm_class="sxiv"),
        Match(wm_class="telegram-desktop"),
        Match(wm_class="streamlink-twitch-gui"),
        Match(wm_class="pinentry-gtk-2"),
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
