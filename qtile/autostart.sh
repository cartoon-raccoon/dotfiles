#!/bin/bash

xautolock -time 5 -locker "/home/sammy/.config/i3/i3lock" &
picom &
feh --bg-scale /home/sammy/Pictures/Wallpaper/streets.jpg

#$HOME/.config/polybar/launch.sh &

pkill mpd_notify.sh; ~/.config/mpd/mpd_notify.sh &
