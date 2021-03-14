#!/bin/bash

# this script exists just to make sure the screenshot gets put into the correct folder
# instead of having scrot dump it in pwd.
# also sends a nice little desktop notif to let you know.
# helpfully provides the -u switch so it can also take the focused window.
# this should be used in conjunction with window manager keybinds,
# one for the whole screen and one for the focused window.

scdir="/home/sammy/Pictures/Screenshots"

# cd in
cd $scdir || mkdir $scdir; cd $scdir

# scrot!
if [ "$1" = -u ] || [ "$1" = --focused ]; then
	scrot -u
	notify-send \
	--app-name="scrot" \
	-h string:bgcolor:#333333 \
	"Screenshot Taken" "current window"
else
	scrot
	notify-send \
	--app-name="scrot" \
	-h string:bgcolor:#333333 \
	"Screenshot Taken" "full screen"
fi

#cd out
cd ~

#notify-send "Screenshot taken"
