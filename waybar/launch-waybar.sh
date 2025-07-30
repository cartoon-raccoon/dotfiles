#!/bin/bash

STYLE_FILE="$HOME/.config/waybar/style.css"

if [ "$XDG_SESSION_DESKTOP" = "Hyprland" ]; then
    CONFIG_FILE="$HOME/.config/waybar/config-hypr.jsonc"
elif [ "$XDG_SESSION_DESKTOP" = "Niri" ]; then
    CONFIG_FILE="$HOME/.config/waybar/config-niri.jsonc"
fi

trap "killall waybar" EXIT

waybar -c "$CONFIG_FILE" -s "$STYLE_FILE" &
while true; do
    inotifywait -e create,modify "$CONFIG_FILE" "$STYLE_FILE"
    killall -SIGUSR2 waybar
done