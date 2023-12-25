#!/usr/bin/env bash

# trigger a small, passive popup dialog to inform the user about darkman's activity
# reference https://wiki.archlinux.org/title/Desktop_notifications#Usage_in_programming


theme=$(darkman get)
PATH="$HOME/.local/bin/:$PATH"

if [ $theme == "dark" ]; then
  sed -i 's/tokyonight_day/tokyonight_storm/g' "$HOME/.config/kitty/kitty.conf"
  sed -i 's/Light/Origin/g' "$HOME/.config/bat/config"
  sed -i 's/flat-remix-light/tokyo-storm/g' "$HOME/.config/btop/btop.conf"
else
  sed -i 's/tokyonight_storm/tokyonight_day/g' "$HOME/.config/kitty/kitty.conf"
  sed -i 's/Origin/Light/g' "$HOME/.config/bat/config"
  sed -i 's/tokyo-storm/flat-remix-light/g' "$HOME/.config/btop/btop.conf"
fi

kill -SIGUSR1 $(pgrep kitty)
tmux source-file "$HOME/.config/tmux/$theme.conf"


# This uses the neovim-remote python package to control other neovim instances.
# see: https://github.com/mhinz/neovim-remote
# Further, it is assumed that toggling the background in neovim is enough.
# Anything else should be handled by the set color scheme.

for server in $(nvr --serverlist); do
    nvr --servername "$server" -cc "set background=$theme"
done
