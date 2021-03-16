#!/bin/bash

feh --bg-scale /home/sammy/Pictures/minimalistwp.png
xautolock -time 5 -locker "/home/sammy/.config/i3/i3lock" &
picom &

$HOME/.config/polybar/launch.sh &

pkill mpd_notify.sh; ~/.config/mpd/mpd_notify.sh &
