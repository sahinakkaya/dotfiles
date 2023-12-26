#!/bin/bash

# Set limit to shell argument
batteryLimit=$1
fullAt=92

# Get the current battery level with acpi
batteryLevel=$(acpi | cut -d ' ' -f 4 | tr -d '%|,| ')
charging=$(acpi | cut -d ' ' -f 3 | tr -d ',| ')

echo $batteryLevel

if [[ "$batteryLevel" -le "$batteryLimit" ]] && [[ "$charging" == "Discharging" ]]; then
    /usr/bin/notify-send -a "Battery Warning" --urgency critical "Battery level at ${batteryLevel}%" -i abrt -t 10000
    /usr/bin/mpv /usr/share/sounds/Oxygen-Sys-Warning.ogg
    # /usr/bin/aplay /usr/share/sounds/freedesktop/stereo/dialog-warning.oga
#elif [[ "$batteryLevel" -gt "$fullAt" ]] && [[ ! "$charging" == "Discharging" ]]; then
#    /usr/bin/notify-send -a "Battery Warning" "Battery is full: ${batteryLevel}" -i abrt -t 10000
#    /usr/bin/paplay /usr/share/sounds/freedesktop/stereo/dialog-warning.oga
fi
