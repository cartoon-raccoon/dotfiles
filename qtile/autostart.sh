#!/bin/bash

xss-lock "/home/sammy/.config/i3/i3lock" &
picom &
feh --bg-scale /home/sammy/Pictures/Wallpaper/dont_fly.png

nm-applet &
#$HOME/.config/polybar/launch.sh &

pkill mpd_notify.sh; ~/.config/mpd/mpd_notify.sh &
