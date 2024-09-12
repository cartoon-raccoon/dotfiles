#!/bin/bash

#export GRIM_DEFAULT_DIR="/home/sammy/Pictures/Screenshots"
scdir="/home/sammy/Pictures/Screenshots"
active_monitor=$(hyprctl activeworkspace | grep "on monitor" | cut -d " " -f 7 | sed 's/:*$//')
filename="$(date '+%Y-%m-%d-%H_%M_%S')-$active_monitor"

function get_active_window() {
	window_info=$()
}

# cd in
cd $scdir || mkdir $scdir; cd $scdir

# grim it!
if [ "$1" = -u ] || [ "$1" = --focused ]; then # taking active window
	true
	notify-send --app-name="grim" -h string:bgcolor:#333333 \
	"Screenshot Taken" "Active Window"
elif [ "$1" = -r ] || [ "$1" = --region ]; then # taking selected region and copying to clipboard
	geometry="$(slurp 2>&1)"
	if [[ "$geometry" == "selection cancelled" ]]; then
		cd ~
		exit
	fi
	# todo: add regex to check for error condition
	grim -g "$geometry" | wl-copy
	notify-send --app-name="grim" -h string:bgcolor:#333333 \
	"Screenshot Taken" "Selected Region to Clipboard"
else # taking entire active monitor
	grim -o $active_monitor $filename.png
	notify-send --app-name="grim" -h string:bgcolor:#333333 \
	"Screenshot Taken" "Full Screen: $active_monitor"
fi

#cd out
cd ~