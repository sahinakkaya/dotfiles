export ZDOTDIR="/home/sahin/.config/zsh"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

export PATH="$PATH:$HOME/scripts:"
export PATH="$PATH:$HOME/.config/rofi/bin/:"
export PATH="$PATH:$HOME/.local/bin/"

[ ! -s ~/.config/mpd/pid ] && mpd
