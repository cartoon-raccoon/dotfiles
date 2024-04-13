#!/bin/bash

WALLPAPER_PATH="/home/sammy/Pictures/Wallpaper"

nm-applet &

bluetoothctl -- power on
#$HOME/.config/polybar/launch.sh &
blueman-applet &

#pkill mpd_notify.sh; ~/.config/mpd/mpd_notify.sh &

# todo: fix this in udev but this is a bodge for now
sudo chmod a+rw /dev/hidraw*