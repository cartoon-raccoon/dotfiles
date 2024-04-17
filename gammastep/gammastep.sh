#!/bin/bash

trap "killall gammastep" EXIT

ping -c 1 -W 50 1.1.1.1 || (notify-send "gammastep: unable to connect to network"; exit)

IFS="," read lat long <<< $(curl --silent https://ipinfo.io | jq .loc | tr -d '"')

# launch the system tray version
gammastep-indicator -l $lat:$long || notify-send "gammastep failed to launch"