#!/bin/bash

trap "killall wlsunset" EXIT

ping -c 1 -W 50 1.1.1.1 || (notify-send "wlsunset failed to launch"; exit)

IFS="," read lat long <<< $(curl --silent https://ipinfo.io | jq .loc | tr -d '"')

wlsunset -l $lat -L $long || notify-send "wlsunset failed to launch"