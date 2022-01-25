#!/bin/bash

# Set path for running in a cron job
PATH='/snap/bin:/home/sahin/.poetry/bin:/home/sahin/.pyenv/bin:/home/sahin/.pyenv/shims:/home/sahin/.pyenv/bin:/home/sahin/.cargo/bin:/home/sahin/.poetry/bin:/home/sahin/.local/bin:/home/sahin/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/usr/lib/jvm/java-8-oracle/bin:/usr/lib/jvm/java-8-oracle/db/bin:/usr/lib/jvm/java-8-oracle/jre/bin:/home/sahin/Downloads/ArchiveFiles/idea-IU-211.7628.21/bin:/home/sahin/scripts:/home/sahin/.fzf/bin'

# Set limit to shell argument
batteryLimit=$1

export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/$(id -u)

# Get the current battery level with acpi
batteryLevel=$(acpi | cut -d ' ' -f 4 | tr -d '%|,| ')
charging=$(acpi | cut -d ' ' -f 3 | tr -d ',| ')

# Must have the Xdus file to run in a cron job. If this is not
# necessary functionality, this can be ignored, otherwise one must
# run the /scripts/xdbus.sh script in this repository at startup,
# which is called by default from my i3/config file.
# if [ -r "$HOME/.dbus/Xdbus" ]; then
#   . "$HOME/.dbus/Xdbus"
# fi

if [[ "$batteryLevel" -le "$batteryLimit" ]] && [[ "$charging" == "Discharging" ]]; then
    /usr/bin/notify-send -a "Battery Warning" --urgency critical "Battery level at ${batteryLevel}%" -i abrt -t 10000
    /usr/bin/paplay /usr/share/sounds/Oxygen-K3B-Finish-Error.ogg
fi
