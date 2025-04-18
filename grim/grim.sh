#!/bin/bash

#export GRIM_DEFAULT_DIR="/home/sammy/Pictures/Screenshots"
scdir="/home/sammy/Pictures/Screenshots"
active_monitor=$(hyprctl activeworkspace | grep "on monitor" | cut -d " " -f 7 | sed 's/:*$//')
filename="$(date '+%Y-%m-%d-%H_%M_%S')-$active_monitor"

function get_active_window() {
	window_info="$(hyprctl activewindow | tr '\t' ' ' | tr '\n' '\t' | cut -d $(printf '\t') -f 4,5)"
}

# cd in
cd $scdir || mkdir $scdir; cd $scdir

# grim it!
if [ "$1" = -u ] || [ "$1" = --focused ]; then # taking active window
	# todo
	# 1. get window dimensions
	# 2. disable blur, borders, rounding, etc.
	# 3. grim and save it
	# 4. re-enable decorations
	notify-send --app-name="grim" -h string:bgcolor:#333333 \
	"Screenshot Taken" "Active Window"
elif [ "$1" = -r ] || [ "$1" = --region ]; then # taking selected region and copying to clipboard
	geometry="$(slurp 2>&1)"
	if [[ "$geometry" == "selection cancelled" ]]; then
		cd ~
		exit
	fi

	if zenity --question --text="Save as file?" --icon=text-x-generic-symbolic; then

		# get filename we want to save
		filename=$(zenity --title="Save Screenshot" --file-selection --save --filename="$filename.png" --file-filter='*.png')
		# if filename doesn't have extension, add it
		if ! [[ "$filename" == *.png ]]; then
			filename="$filename.png"
		fi

		# wait one second for the file selection window to clear
		sleep 1

		# do screenshot
		grim -g "$geometry" "$filename"
		notify-send --app-name="grim" -h string:bgcolor:#333333 \
		"Screenshot Taken" "Saved as $filename"
	else
		sleep 1
		# todo: add regex to check for error condition
		grim -g "$geometry" - | wl-copy
		notify-send --app-name="grim" -h string:bgcolor:#333333 \
		"Screenshot Taken" "Selected Region to Clipboard"
	fi
else # taking entire active monitor
	grim -o $active_monitor $filename.png
	notify-send --app-name="grim" -h string:bgcolor:#333333 \
	"Screenshot Taken" "Full Screen: $active_monitor"
fi

#cd out
cd ~