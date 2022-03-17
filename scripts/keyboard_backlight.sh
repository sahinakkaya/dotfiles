#!/bin/bash



brightness=`cat /sys/class/leds/asus::kbd_backlight/brightness`
max=3
min=0


if [ "$1" == "inc" ]; then

    brightness=`expr $brightness + 1`
else
    brightness=`expr $brightness - 1`
fi

if [ $brightness -gt 3 ]; then
  brightness=3
fi

if [ $brightness -lt 0 ]; then
  brightness=0
fi

echo $brightness > /sys/class/leds/asus::kbd_backlight/brightness
