#!/bin/bash

trap "killall gammastep" EXIT

# since we're usually getting started at boot, sleep for 2 seconds for us
# to get connected to a network
sleep 2

ping -c 1 -W 50 1.1.1.1 || (notify-send "gammastep: unable to connect to network"; exit)

IFS="," read lat long <<< $(curl --silent https://ipinfo.io | jq .loc | tr -d '"')

# launch the system tray version
gammastep-indicator -l $lat:$long -t 6500:3500 || notify-send "gammastep failed to launch"