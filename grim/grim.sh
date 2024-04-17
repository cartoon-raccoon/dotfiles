#!/bin/bash

scdir="/home/sammy/Pictures/Screenshots"

# cd in
cd $scdir || mkdir $scdir; cd $scdir

# grim it!
if [ "$1" = -u ] || [ "$1" = --focused ]; then
	grim -g $(slurp)
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
grim -g (slurp)