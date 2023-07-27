#!/bin/bash

WALLPAPER_PATH="/home/sammy/Pictures/Wallpaper"

xss-lock "/home/sammy/.config/i3/i3lock" &
picom &
#feh --bg-fill "$WALLPAPER_PATH/$DESKTOP_BKGD"

nm-applet &

bluetoothctl -- power on
#$HOME/.config/polybar/launch.sh &


pkill mpd_notify.sh; ~/.config/mpd/mpd_notify.sh &
