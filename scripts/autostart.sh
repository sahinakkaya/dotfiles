#!/bin/sh

function run {
	if ! pgrep $1 > /dev/null ;
	then
		$@&
	fi
}

#feh --bg-scale /usr/share/endeavouros/backgrounds/endeavouros-wallpaper.png

rm ~/.cache/workspaces
nitrogen --save --set-zoom-fill ~/Pictures/Wallpapers/default.jpg
# run picom --experimental-backends -b # --vsync should prevent screen tearing on most setups if needed
run picom -b # --vsync should prevent screen tearing on most setups if needed

eww -c ~/.config/eww/bar/ close-all
eww -c ~/.config/eww/bar/ open bar

keynav daemonize

/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 & disown # start polkit agent from GNOME
