#!/bin/bash

ext_display_connected=false
if hyprctl monitors | grep "DP-1" > /dev/null; then
    ext_display_connected=true
fi

case $1 in
-d)
    action="dim"
;;

-r)
    action="reset"
;;
esac

dimbrightness=50
fullbrightness=90

if [[ "$action" == "dim" ]]; then
    brightnessctl -s set 10 > /dev/null
    $ext_display_connected && ddcutil setvcp 10 $dimbrightness
elif [[ "$action" == "reset" ]]; then
    brightnessctl -r > /dev/null
    $ext_display_connected && ddcutil setvcp 10 $fullbrightness
fi

exit 0