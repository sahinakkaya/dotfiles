# Kitty keybinding format and design

This document describes the format and implementation, not the current shortcut
assignments. `keybindings.toml` is the source of truth; use the overlay as the
shortcut reference. Examples below illustrate syntax and are not a binding list.

Edit **keybindings.toml** for keyboard shortcuts, mouse bindings, and guide labels.
`kitty.conf` loads `keybindings.py` with Kitty's `geninclude` directive. It compiles
the TOML during startup or config reload, using Kitty's embedded Python. There is
no generated file to maintain and no additional dependency to install.

After changing TOML, apply the chezmoi changes. Opening the guide detects changed
prefix mappings and reloads Kitty's config before entering the mode. For global
bindings, aliases, or settings, reload Kitty explicitly. A fresh instance also
loads the changes. TOML edits alone do not guarantee an automatic reload.

## Groups and actions

```toml
[[groups]]
name = "Scrolling"
mode = "kitty_prefix"

[[groups.actions]]
name = "Scroll lines"
bindings = [
  { keys = ["j"], label = "Down", action = "scroll_line_down" },
  { keys = ["k"], label = "Up", action = "scroll_line_up" },
]
```

- `groups.name` organizes actions in the source file. Group titles are hidden
  in the guide. Actions appear first; submenus follow with a `+` marker,
  italic text, and the theme's blue accent.
- `groups.mode` selects the Kitty keyboard mode; `""` means global shortcuts.
- At the top level, each `groups.actions` table is one row in the guide. Sharing
  this table is an explicit decision to show bindings together; actions are never grouped by
  guessing from their commands or key names. Inside submenus each binding and
  alias has its own row, with its variant label where provided.
- `name` describes the action in plain language.
- `bindings` lists the actual Kitty commands. Each binding has one or more
  `keys`, an `action`, and an optional `label` describing that variant. Variants
  appear in matching key/label order.
- A `keys` list can contain aliases, such as `["delete", "backspace"]`. Use
  Kitty's normal key syntax, including `shift+c` and multi-key sequences `i>f`.
- `show` is an optional boolean on each binding, defaulting to `true`.
  Set `show = false` to hide its leaf hint without disabling the shortcut:
  `{ keys = ["j"], action = "scroll_line_down", show = false }`.
  Submenu prefixes remain discoverable even when all their leaves are hidden.
  To hide just one alias, put it in a separate binding with the same action.
  Partial hiding also disables an action's compact `keys_label`, so it cannot
  advertise hidden keys. Visibility edits take effect when reopening the guide.
- `repeat_timeout` is an optional nonnegative number of seconds, defaulting to
  `0` (ordinary dispatch). A positive value executes the action immediately,
  keeps its submenu open, and closes the guide after that many seconds without
  another repeatable action. Each repeat restarts the timer. The timer begins
  only after the first repeatable action, not when entering the prefix/submenu.
  For example:
  `{ keys = ["b>i"], action = "set_background_opacity +0.1", repeat_timeout = 2.0 }`.
  Hidden bindings can repeat too. Escape/F18 closes the guide; Backspace leaves
  the submenu and cancels the repeat timeout. One-shot bindings retain their
  ordinary behavior. Use repeat settings for adjustments rather than actions
  that open another prompt or window.
- Commands use Kitty's normal action syntax. Include
  `combine : pop_keyboard_mode : ...` for actions that leave prefix mode.
  Commands without it remain repeatable, as before.

The example displays `j/k → Scroll lines (Down / Up)`. Each key still executes
its own command. Source order controls the order of the guide's groups/actions.

## Custom key labels

Use `keys_label` to explicitly choose a compact top-level display instead of
listing every key. Submenus always display individual keys. This affects only
the guide, never the actual mappings:

```toml
[[groups.actions]]
name = "Go to tab 1–3"
keys_label = "1–3"
bindings = [
  { keys = ["1"], action = "combine : pop_keyboard_mode : goto_tab 1" },
  { keys = ["2"], action = "combine : pop_keyboard_mode : goto_tab 2" },
  { keys = ["3"], action = "combine : pop_keyboard_mode : goto_tab 3" },
]
```

## Other sections

- `version = 1` identifies this format.
- `[settings]` holds `kitty_mod`, `map_timeout`, `clear_all_shortcuts`, and
  `show_delay`. The latter is the delay in seconds before displaying the guide
  (default `0.35`; `0` displays immediately). It does not delay key handling.
- `[aliases]` maps action-alias names to their Kitty command strings.
- `[[modes]]` declares a mode's `name`, activation `key`, and `timeout`. The
  guide activation binding invokes `which_key.py` instead of just entering the mode.
- `[prefixes]` names intermediate sequences, such as `i = "Copy text"` or
  `"i>g" = "Copy Git information"`.
- Each `[[mouse]]` has a descriptive `name`, a Kitty `gesture` (for example,
  `"right press ungrabbed"`), and an `action`.

Unknown fields and duplicate keyboard bindings within a mode are rejected.
Kitty validates the generated key names and commands with its normal parser.

The guide reads descriptions from TOML and matches them against Kitty's loaded
bindings. It continues to execute Kitty's live mappings, so reload the config
after changing commands or keys, or reopen the guide to refresh prefix mappings.

## Guide and command execution

`which_key.py` reads the live Kitty mappings and attaches descriptions from TOML.
With a positive `show_delay`, `which_key_pending.py` initially lets Kitty's native
mapping dispatcher execute shortcuts, without starting a UI process. A completed
one-shot shortcut cancels the pending display timer. Temporary dispatch handling
preserves submenu repeat state and supports Backspace/cancellation; it is removed
when the session ends or hands over to the UI.

If the delay expires, the UI in `which_key_ui.py` opens with the current submenu
and any remaining repeat deadline. It collects subsequent keys, then replays the
complete sequence through Kitty's native dispatcher after closing. Already-run
actions are not replayed. Once the UI is open, ordinary non-exiting commands
reopen it at the root; one-shot commands exit the prefix mode.

Bindings with a positive `repeat_timeout` execute immediately in both phases.
Before the UI opens, native sequence state is retained so the next press remains
in the same submenu. Once open, the custom kitten receives an inherited remote-control file descriptor
restricted to the `action` command. It invokes `repeat_action.py` against the
original pane, preserving the guide's input mode even if the command includes
`pop_keyboard_mode`. No global remote-control listener is needed. Keeping the
same UI process alive preserves queued rapid keypresses. Already executed repeat
actions are not replayed when the guide closes.

The launcher normalizes the new channel's command restriction to a tuple. Kitty
0.47.1 otherwise passes a string where its authorizer expects a sequence of
command names, incorrectly treating the command name as individual characters.

The guide temporarily spans the OS window, preserving the original layout and
pane dimensions. Its bottom panel uses snapshots of visible pane text as a
backdrop. The backdrop is static while the guide is open. Closing the guide
restores the layout before executing commands against the original pane.

When needed, the guide starts as an invisible input window while it initializes.
The layout preserves the original panes and borders. The kitten declares a ready
handshake so Kitty buffers keys arriving during process startup. Once its first
frame is written, `reveal_guide.py` reveals it through the scoped action channel.
Input readiness and visual visibility are independent. `show_delay` is measured
from prefix activation, independently of repeat and mapping timeouts; setting it
to zero starts the guide immediately. Display timers are cancelled on exit.

Keys that begin longer sequences are discovered from the live mappings; the
`[prefixes]` table supplies their names. Submenus use a `+` marker, italics, and
a theme palette color. Leaves precede submenus. Modifier-only events are ignored
while waiting for a complete shortcut. Colors inherit the active pane's theme.

## Argument prompts and action catalog

The action catalog is explicitly maintained in TOML, rather than automatically
assigning keys from Kitty's available actions. It can be reorganized without
changing the compiler or guide. Platform-specific and mouse-context actions
are labeled to explain where they apply.

An **…** label means the action needs arguments. It invokes `action_prompt.py`, opening an input prompt with
Kitty's help text and the action name prefilled. For example, complete
`copy_to_buffer ` as `copy_to_buffer notes`. Enter runs it in the original pane;
Escape cancels. The guide closes before the command/prompt runs. Mouse actions
still use Kitty's mouse context; macOS actions are labeled explicitly.

Tests verify action
coverage against the installed Kitty version, complete default-shortcut coverage,
and absence of sequence-prefix collisions.

## Validation

From the repository root:

```sh
kitty +runpy 'import runpy; runpy.run_path("tests/kitty_keybindings.py", run_name="__main__")'
```
