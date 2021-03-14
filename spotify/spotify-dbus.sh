#!/bin/bash

dest="org.mpris.MediaPlayer2.spotify"
objpath="/org/mpris/MediaPlayer2"
interface="org.mpris.MediaPlayer2.Player"

case $1 in
	-t)
		dbus-send --print-reply --dest=$dest $objpath $interface.PlayPause
		;;
	-n)
		dbus-send --print-reply --dest=$dest $objpath $interface.Next
		;;
	-p)
		dbus-send --print-reply --dest=$dest $objpath $interface.Previous
		;;
	-s)
		dbus-send --print-reply --dest=$dest $objpath $interface.Stop
		;;
	*)
		echo -n "Unknown"
		exit 1
		;;
esac
