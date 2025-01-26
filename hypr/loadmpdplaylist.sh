#!/bin/bash
playlist=$(zenity --forms --text="Select Playlist" --add-combo=Playlist --combo-values=$(mpc lsplaylists | awk '{printf "%s|", $0}'))
if [ $? = "1" ]; then exit; fi
mpc clear
mpc load "$playlist"