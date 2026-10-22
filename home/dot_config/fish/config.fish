set -gx EDITOR vim
set -gx VISUAL vim
if not set -q XDG_CONFIG_HOME
    set -gx XDG_CONFIG_HOME "$HOME/.config"
end
fish_add_path --path "$HOME/.local/bin"

if test -r "$XDG_CONFIG_HOME/shell/common-aliases"
    source "$XDG_CONFIG_HOME/shell/common-aliases"
end

if status is-interactive
    set -g fish_greeting
    # Commands to run in interactive sessions can go here
    bind \cg accept-autosuggestion
    bind \cf forward-word
    bind \cb backward-word
    alias crontab='crontab -i'
end
