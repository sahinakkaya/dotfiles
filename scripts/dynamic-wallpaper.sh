#!/bin/bash

# get todays md5sum and extract first 2 chars then convert it to base 10
todays_hash=$(date +%x | md5sum | cut -c 1-2)
base10=$(echo "ibase=16;$todays_hash" | bc)

# calculate the index for the wallpaper set: base10 % num_of_dirs
dirs=$(find ~/Pictures/Wallpapers/time-based/* -maxdepth 1 -type d)
num_of_dirs=$(echo "${dirs}" | wc -l)
index=$(echo "${base10} % ${num_of_dirs} + 1" | bc) 
wallpaper_set=$(echo "${dirs}"| sed -n "${index}p")

# get the file path based on the current hour of the day
num=$(date +%-H)
image="$wallpaper_set/$num"
if [[ -f "${image}.png" ]]; then
    format="png"
elif [[ -f "${image}.jpg" ]]; then
    format="jpg"
else
    notify-send "Could not find any image for $image"
fi
path="$wallpaper_set/$num.$format"
echo "path: $path"
actual_file=$(readlink -f $path)

set_wallpaper() {
  wal -st -i $1 --backend=haishoku
  python3 ~/scripts/misc/adjust_terminal_colors.py rgb 0.5
  ~/scripts/misc/restart_dunst.sh
  xrdb ~/.Xresources

}
# if the current wallpaper is different than the previous one, set it
[[ $(< ~/.last_wallpaper_path) != "$actual_file" ]] && set_wallpaper $actual_file
echo "$actual_file" > ~/.last_wallpaper_path
