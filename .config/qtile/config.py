from modules.groups import groups
from modules.keys import keys, mod
from modules.layouts import floating_layout, layouts
from modules.mouse import mouse
from modules.hooks import *
from modules.screens import screens

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
main = None  # WARNING: this is deprecated and will be removed soon
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "urgent"
wmname = "LG3D"
widget_defaults = dict(
    font="Cascadia Code", fontsize=16, padding=12, foreground="CEC8C6"
)
