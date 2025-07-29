#!/bin/bash

CONFIG_FILES="$HOME/.config/waybar/config.jsonc $HOME/.config/waybar/style.css"

trap "killall waybar" EXIT

waybar -s $HOME/.config/waybar/style.css &
while true; do
    inotifywait -e create,modify $CONFIG_FILES
    killall -SIGUSR2 waybar
done