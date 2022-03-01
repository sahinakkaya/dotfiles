#!/bin/sh
killall dunst
dunst & 
notify-send "Environment reloaded!"
