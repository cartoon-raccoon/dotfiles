#!/bin/bash

WALLPAPER_PATH="/home/sammy/Pictures/Wallpaper"

xss-lock "/home/sammy/.config/i3/i3lock" &
picom &
feh --bg-scale $WALLPAPER_PATH/meme.png

nm-applet &

bluetoothctl -- power on
#$HOME/.config/polybar/launch.sh &

#! NOTE: running polkit authenticator here means it will only work on qtile
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

pkill mpd_notify.sh; ~/.config/mpd/mpd_notify.sh &
