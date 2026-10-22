#!/usr/bin/env bash

# trigger a small, passive popup dialog to inform the user about darkman's activity
# reference https://wiki.archlinux.org/title/Desktop_notifications#Usage_in_programming

. "$HOME/.local/bin/env"

theme=$1
echo "$theme" > ~/.theme

chezmoi apply

# kill -SIGUSR1 $(pgrep kitty)
pkill -USR1 -u "$(id -u)" -x kitty
# tmux source-file "$HOME/.config/tmux/$theme.conf"


# This uses the neovim-remote python package to control other neovim instances.
# see: https://github.com/mhinz/neovim-remote
# Further, it is assumed that toggling the background in neovim is enough.
# Anything else should be handled by the set color scheme.

for server in $(nvr --serverlist); do
    nvr --servername "$server" -cc "set background=$theme"
done
