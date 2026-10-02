#!/bin/bash

# shellcheck disable=SC2046,SC2034

STYLE_FILE="$HOME/.config/waybar/style.css"
SCRIPT_FILE="$HOME/.config/waybar/launch-waybar.sh"

if [ "$XDG_SESSION_DESKTOP" = "Hyprland" ]; then
    if [ "$(hostname)" = "cartoonraccoon" ]; then
        CONFIG_FILE="$HOME/.config/waybar/config-hypr-laptop.jsonc"
    elif [ "$(hostname)" = "raccoonpc" ]; then
        CONFIG_FILE="$HOME/.config/waybar/config-hypr.jsonc"
    fi
elif [ "$XDG_SESSION_DESKTOP" = "Niri" ]; then
    CONFIG_FILE="$HOME/.config/waybar/config-niri.jsonc"
fi

trap die EXIT

function die() {
    echo "exiting..." >&2
    kill $(jobs -p)
}

function start_waybar() {
    # if at least one waybar instance exists, kill them
    if pidof waybar; then
        pkill waybar
    fi
    waybar -c "$CONFIG_FILE" -s "$STYLE_FILE" > /dev/null 2>&1 &
}

start_waybar

while true; do
    read -r modded action <<< $(inotifywait -e modify "$CONFIG_FILE" "$STYLE_FILE" "$SCRIPT_FILE" 2> /dev/null)
    if [ "$modded" = "$SCRIPT_FILE" ]; then
        notify-send -t 5000 "Waybar Launcher" "Script file $SCRIPT_FILE was modified, re-executing" >&2
        exec bash "$SCRIPT_FILE"
    else
        notify-send -t "Waybar config file $modded was modified, sending SIGUSR2" >&2
        killall -SIGUSR2 waybar || start_waybar
    fi
done
