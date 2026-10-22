-- Keyboard layouts and per-device overrides. Custom XKB variants must remain installed.

hl.config({
    input = {
        kb_layout = "tr,us",
        kb_variant = "legacy-fix-ansi,",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true,
            drag_lock = true,
            disable_while_typing = true,
        },
        sensitivity = 0,
    },
})

hl.device({
    name = "compx-2.4g-receiver-mouse",
    sensitivity = -1,
})

hl.device({
    name = "apple-mtp-keyboard",
    kb_layout = "tr,us",
    kb_variant = "legacy-fix-iso,",
    kb_model = "",
    kb_options = "altwin:alt_super_win,shift:both_capslock_cancel,lv3:ralt_switch,caps:ctrl_modifier",
    kb_rules = "",
})

hl.device({
    name = "keymapper",
    kb_layout = "tr,us",
    kb_variant = "legacy-fix-iso,",
    kb_options = "altwin:alt_super_win,shift:both_capslock_cancel,lv3:ralt_switch,caps:ctrl_modifier,fkeys:basic_13-24",
})

hl.on("hyprland.start", function()
    hl.exec_cmd("keymapper -u")
end)
