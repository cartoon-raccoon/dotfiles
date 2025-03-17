#/bin/bash

if [ "$1" = -s ]; then
    # off display
    hyprctl dispatch dpms off
    # sleep duckypad
    hyprctl dispatch event sleep
elif [ "$1" = -w ]; then
    # on display
    hyprctl dispatch dpms on
    # wake duckypad
    hyprctl dispatch event wake
fi