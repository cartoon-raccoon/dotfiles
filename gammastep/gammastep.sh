#!/bin/bash

trap "killall gammastep" EXIT

LOCATION_FILE="$HOME/.gammastep_loc"
LOCATION="0.0000:0.0000"

# since we're usually getting started at boot, sleep for 2 seconds for us
# to get connected to a network
sleep 2


ping -c 1 -W 50 1.1.1.1 || $LOCATION=$(< $LOCATION_FILE)

IFS="," read lat long <<< $(curl --silent https://ipinfo.io | jq .loc | tr -d '"')
LOCATION="$lat:$long"
echo $LOCATION
echo "$LOCATION" > $LOCATION_FILE


# launch the system tray version
gammastep-indicator -l $LOCATION -t 6500:3500 || notify-send "gammastep failed to launch"