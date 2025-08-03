#!/bin/bash

# a script to take screenshots on Hyprland.
# requires grim-hyprland (https://github.com/eriedaberrie/grim-hyprland).

# options:
# -w: capture the active window; -r: capture a selected region, -m: capture the active monitor.
#
# by default, the screen capture is saved to the clipboard using wl-copy. if you want to
# save it to a file instead, append `s` to the capture option, e.g. -ws captures the active
# window and saves it to a file you select with a file chooser.

scdir="$HOME/Pictures/Screenshots"
base_filename="$(date '+%Y-%m-%d-%H_%M_%S')"
cache_folder="$HOME/.cache/grim"
save_to_file=false

if ! (which hyprctl \
	 && which grim \
	 && which slurp \
	 && which zenity \
	 && which notify-send \
	 && which wl-copy \
	 && which which jq \
) > /dev/null; then
	echo "error: one or more dependent commands could not be found" >&2
	exit 1
fi

# create cache folder if it doesn't already exist
[ -e "$cache_folder" ] || mkdir -p "$cache_folder"

# reset the hyprctl submap if needed
if [[ "$(hyprctl submap)" != default* ]]; then
	hyprctl dispatch submap reset
fi

# cd in
cd "$scdir" || mkdir -p "$scdir"; cd "$scdir" || exit

if [[ "$1" == *s* ]]; then
	save_to_file=true
fi

if [[ "$1" == *w* ]]; then # screenshotting active window

	windowinfo="$(hyprctl activewindow -j)"
	window_addr="$(jq -r '.address' <<< "$windowinfo")"
	# use initialTitle since windows may change their titles depending on context (e.g. VSCode, Alacritty)
	windowtitle="$(jq -r '.initialTitle' <<< "$windowinfo")"

	CMD="grim -w $window_addr"
	NOTIF_MSG="Active Window: $windowtitle"
	
elif [[ "$1" == *r*  ]]; then # screenshotting selected region

	geometry="$(slurp 2>&1)"
	if [[ "$geometry" == "selection cancelled" ]]; then
		echo "selection cancelled, exiting"
		exit
	fi

	CMD="grim -g \"$geometry\""
	NOTIF_MSG="Selected Region: $geometry"
	
elif [[ "$1" == *m* ]]; then # screenshotting active monitor

	active_monitor=$(hyprctl activeworkspace -j | jq -r '.monitor')

	CMD="grim -o \"$active_monitor\""
	NOTIF_MSG="Active Monitor: $active_monitor"
	
else
	echo "error: no option given" >&2
	exit 1
fi

cached_filename="$cache_folder/$base_filename.png"
echo "cached as $cached_filename" >&2

if $save_to_file; then

	# grim it!
	if ! eval "$CMD \"$cached_filename\""; then
		echo "error while running grim" >&2
		exit 1
	fi

	# get filename we want to save
	filepath=$(zenity \
		--title="Save Screenshot" \
		--file-selection \
		--save --filename="$base_filename.png" \
		--file-filter='*.png')
	
	if [ $? -ne 0 ]; then # zenity exits with a non-zero exit code if cancelled
		echo "file selection cancelled, exiting" >&2
		rm "$cached_filename"
		exit
	fi
	# if filename doesn't have extension, add it
	if ! [[ "$filepath" == *.png ]]; then
		if [ -z "$filepath" ]; then
			filepath="$base_filename"
		fi
		filepath="$filepath.png"
	fi

	# move to destination (filepath)
	echo "saving to $filepath" >&2
	mv "$cached_filename" "$filepath"

	icon="$filepath"

	# update notification message
	NOTIF_MSG="$(printf '%s\n%s' "$NOTIF_MSG" "Saved to $filepath")"

else # we want to copy to clipboard

	# grim it!
	if ! eval "$CMD - | tee $cached_filename | wl-copy"; then
		echo "error while running grim" >&2
		exit 1
	fi

	icon="$cached_filename"

	NOTIF_MSG="$(printf '%s\n%s' "$NOTIF_MSG" "Copied to clipboard")"
fi

notify-send --app-name="grim" -h string:bgcolor:#333333 \
	--icon="$icon" \
	"Screenshot Taken" \
	"$NOTIF_MSG"

[ -e "$cached_filename" ] && rm "$cached_filename"

#cd out
cd ~ || exit