#!/bin/sh

function run {
	if ! pgrep $1 > /dev/null ;
	then
		$@&
	fi
}

feh --bg-scale /usr/share/endeavouros/backgrounds/endeavouros-wallpaper.png
run picom & disown # --experimental-backends --vsync should prevent screen tearing on most setups if needed

# Low battery notifier
#~/.config/qtile/scripts/check_battery.sh & disown

# Start welcome
#run eos-welcome & disown
run /home/sahin/.config/openbox/polybar/default/launch.sh & disown

run /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 & disown # start polkit agent from GNOME
