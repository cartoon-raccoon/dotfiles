#!/bin/bash

xss-lock "/home/sammy/.config/i3/i3lock" &
picom &
feh --bg-scale /home/sammy/Pictures/Wallpaper/dont_fly.png

nm-applet &
#$HOME/.config/polybar/launch.sh &

#! NOTE: running polkit authenticator here means it will only work on qtile
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

pkill mpd_notify.sh; ~/.config/mpd/mpd_notify.sh &
