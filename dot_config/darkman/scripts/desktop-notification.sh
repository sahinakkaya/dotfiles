#!/usr/bin/env bash

# trigger a small, passive popup dialog to inform the user about darkman's activity
# reference https://wiki.archlinux.org/title/Desktop_notifications#Usage_in_programming

notify-send --app-name="darkman" --urgency=low --icon=weather-clear-night "switching to $1 mode"
