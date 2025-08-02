#!/bin/bash
# shellcheck disable=2046,2034

TAILDROP_DIR="$HOME/Taildrop"

function die() {
    kill $(jobs -p)
}

trap die EXIT

tailscale file get --loop --conflict=rename "$TAILDROP_DIR" &

inotifywait -m -e create "$TAILDROP_DIR" 2> /dev/null | while read -r dir action file; do
    notify-send -t 5000 --icon=document-save "Taildrop" "Received file: $file"
done