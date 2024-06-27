#!/bin/bash

WALLPAPER_PATH="/home/sammy/Pictures/Wallpaper"

xss-lock "/home/sammy/.config/i3/i3lock" &
picom &
#feh --bg-fill "$WALLPAPER_PATH/$DESKTOP_BKGD"
xset s on
xset s 600

nm-applet &

bluetoothctl -- power on
#$HOME/.config/polybar/launch.sh &
blueman-applet &

pkill mpd_notify.sh; ~/.config/mpd/mpd_notify.sh &

# todo: fix this in udev but this is a bodge for now
sudo chmod a+rw /dev/hidraw*