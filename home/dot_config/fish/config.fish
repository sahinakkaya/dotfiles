set -gx EDITOR vim
set -gx VISUAL vim
if not set -q XDG_CONFIG_HOME
    set -gx XDG_CONFIG_HOME "$HOME/.config"
end
fish_add_path --path "$HOME/.local/bin"

if status is-interactive
    set -g fish_greeting
end
