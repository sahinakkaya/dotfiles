-- Lua configuration for Hyprland 0.56.2.
-- The original .conf files are retained as a migration backup.

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x1107", scale = 2.0 })

hl.env("XCURSOR_SIZE", "24")

hl.env("QT_QPA_PLATFORMTHEME", "kde")

hl.env("QT_STYLE_OVERRIDE", "Breeze")

hl.env("GDK_SCALE", "1")

require("keyboard_layouts")

hl.config({
    general = {
        gaps_in = 2,
        gaps_out = 8,
        border_size = 2,
        col = {
            active_border = { colors = { "rgba(F9DEA9ee)", "rgba(F2C294ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        layout = "master",
        allow_tearing = false,
    },
})

hl.config({
    decoration = {
        rounding = 10,
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
        },
        dim_inactive = true,
        dim_strength = 0.05,
        dim_around = 0.5,
    },
})

hl.config({
    animations = {
        enabled = true,
    },
})

hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    master = {
        new_status = "inherit",
        allow_small_split = false,
        slave_count_for_center_master = 2,
        orientation = "center",
    },
})

hl.config({
    gestures = {
        workspace_swipe_cancel_ratio = 0.20,
    },
})

hl.config({
    misc = {
        force_default_wallpaper = -1,
    },
})

hl.config({
    binds = {
        workspace_back_and_forth = true,
        allow_workspace_cycles = true,
    },
})

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.1 } } })
hl.curve("easeOutBack", { type = "bezier", points = { { 0.075, 0.82 }, { 0.165, 1 } } })
hl.curve("easeInBack", { type = "bezier", points = { { 0.075, 0.82 }, { 0.165, 1 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "default", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "easeInBack", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "overshot" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 10, bezier = "default", style = "once" })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "default", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "easeOutBack", style = "slidefadevert" })

hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })

hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, float = true })

hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, float = true, pin = true })

hl.window_rule({ match = { class = "^GLava$" }, float = true, no_blur = true, focus_on_activate = false, no_focus = true, border_size = 0, no_shadow = true, size = "1050 35", move = "230 1", pin = true })

hl.window_rule({ match = { class = "^(org.gnupg.pinentry-qt)$" }, dim_around = true })

hl.window_rule({ match = { class = "^(wofi)$" }, stay_focused = true, border_size = 0 })

hl.window_rule({
    name = "hide-xwaylandvideobridge",
    match = { class = "^(xwaylandvideobridge)$" },
    float = true,
    no_initial_focus = true,
    no_focus = true,
    no_anim = true,
    no_blur = true,
    max_size = "1 1",
    opacity = 0.0,
})

-- Preserve duplicate bindings: some keys intentionally perform multiple actions.

hl.bind("SUPER + tab", hl.dsp.focus({ workspace = "previous" }))
hl.bind("SUPER + return", hl.dsp.exec_cmd("kitty --single-instance"))
hl.bind("SUPER + q", hl.dsp.window.close())
hl.bind("SUPER + c", hl.dsp.exec_cmd("smart-exec"))
hl.bind("SUPER + CONTROL + q", hl.dsp.exec_cmd("uwsm stop"))
hl.bind("SUPER + w", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + w", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind("SUPER + CONTROL + n", hl.dsp.exec_cmd("lock-screen"))
hl.bind("SUPER + semicolon", hl.dsp.exec_cmd("wofi-auto --show drun --normal-window"))
hl.bind("SUPER + SHIFT + p", hl.dsp.exec_cmd("passmenu"))
hl.bind("SUPER + o", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + y", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + v", hl.dsp.exec_cmd("rofi-tailscale --toggle"))
hl.bind("SUPER + y", hl.dsp.window.pin())
hl.bind("SUPER + t", hl.dsp.group.toggle())
hl.bind("SUPER + s", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + m", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind("SUPER + e", hl.dsp.layout("swapwithmaster master"))
hl.bind("SUPER + space", hl.dsp.layout("orientationnext"))
hl.bind("SUPER + SHIFT + m", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SUPER + SHIFT + n", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind("SUPER + h", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + l", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + k", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + j", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + SHIFT + h", hl.dsp.window.swap({ direction = "left" }))
hl.bind("SUPER + SHIFT + l", hl.dsp.window.swap({ direction = "right" }))
hl.bind("SUPER + SHIFT + k", hl.dsp.window.swap({ direction = "up" }))
hl.bind("SUPER + SHIFT + j", hl.dsp.window.swap({ direction = "down" }))
hl.bind("SUPER + left", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + down", hl.dsp.window.move({ direction = "down" }))
hl.bind("SUPER + up", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + CONTROL + h", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + CONTROL + l", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + CONTROL + k", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind("SUPER + CONTROL + j", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
hl.bind("SUPER + p", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + n", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + a", hl.dsp.focus({ workspace = "1" }))
hl.bind("SUPER + s", hl.dsp.focus({ workspace = "2" }))
hl.bind("SUPER + d", hl.dsp.focus({ workspace = "3" }))
hl.bind("SUPER + f", hl.dsp.focus({ workspace = "4" }))
hl.bind("SUPER + g", hl.dsp.focus({ workspace = "5" }))
hl.bind("SUPER + 1", hl.dsp.focus({ workspace = "1" }))
hl.bind("SUPER + 2", hl.dsp.focus({ workspace = "2" }))
hl.bind("SUPER + 3", hl.dsp.focus({ workspace = "3" }))
hl.bind("SUPER + 4", hl.dsp.focus({ workspace = "4" }))
hl.bind("SUPER + 5", hl.dsp.focus({ workspace = "5" }))
hl.bind("SUPER + 6", hl.dsp.focus({ workspace = "6" }))
hl.bind("SUPER + 7", hl.dsp.focus({ workspace = "7" }))
hl.bind("SUPER + 8", hl.dsp.focus({ workspace = "8" }))
hl.bind("SUPER + 9", hl.dsp.focus({ workspace = "9" }))
hl.bind("SUPER + comma", hl.dsp.window.swap({ prev = true }))
hl.bind("SUPER + period", hl.dsp.window.swap({ next = true }))
hl.bind("SUPER + SHIFT + a", hl.dsp.window.move({ workspace = "1" }))
hl.bind("SUPER + SHIFT + s", hl.dsp.window.move({ workspace = "2" }))
hl.bind("SUPER + SHIFT + d", hl.dsp.window.move({ workspace = "3" }))
hl.bind("SUPER + SHIFT + f", hl.dsp.window.move({ workspace = "4" }))
hl.bind("SUPER + SHIFT + g", hl.dsp.window.move({ workspace = "5" }))
hl.bind("SUPER + SHIFT + 1", hl.dsp.window.move({ workspace = "1" }))
hl.bind("SUPER + SHIFT + 2", hl.dsp.window.move({ workspace = "2" }))
hl.bind("SUPER + SHIFT + 3", hl.dsp.window.move({ workspace = "3" }))
hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = "4" }))
hl.bind("SUPER + SHIFT + 5", hl.dsp.window.move({ workspace = "5" }))
hl.bind("SUPER + SHIFT + 6", hl.dsp.window.move({ workspace = "6" }))
hl.bind("SUPER + SHIFT + 7", hl.dsp.window.move({ workspace = "7" }))
hl.bind("SUPER + SHIFT + 8", hl.dsp.window.move({ workspace = "8" }))
hl.bind("SUPER + SHIFT + 9", hl.dsp.window.move({ workspace = "9" }))
hl.bind("SUPER + 0", hl.dsp.workspace.toggle_special("magic2"))
hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = "special:magic2" }))
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("light -A 1; light -O"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("light -U 1; light -O"), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("volume up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("volume down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("volume toggle-mute"), { locked = true, repeating = true })
hl.bind("F4", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | swappy -f -"), { locked = true, repeating = true })
hl.bind("SUPER + x", hl.dsp.exec_cmd("grim - | swappy -f -"), { locked = true, repeating = true })
hl.bind("switch:off:Apple SMC power/lid events", hl.dsp.exec_cmd("$HOME/.local/bin/hypr-lid open"), { locked = true })
hl.bind("switch:on:Apple SMC power/lid events", hl.dsp.exec_cmd("$HOME/.local/bin/hypr-lid close"), { locked = true })
hl.bind("SUPER + j", hl.dsp.group.prev())
hl.bind("SUPER + k", hl.dsp.group.next())
hl.bind("SUPER + h", hl.dsp.group.prev())
hl.bind("SUPER + l", hl.dsp.group.next())

hl.on("hyprland.start", function()
    hl.exec_cmd("ashell")
    hl.exec_cmd("$HOME/.config/glava/glava")
    hl.exec_cmd("/usr/libexec/kf6/polkit-kde-authentication-agent-1")
    hl.exec_cmd("swayidle -w timeout 120 'dim-screen &' resume 'undim-screen'")
    hl.exec_cmd("swayidle timeout 10 'if pgrep -x swaylock; then dim-screen; fi' resume 'undim-screen'")
end)
