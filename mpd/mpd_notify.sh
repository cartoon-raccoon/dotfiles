#!/bin/bash

# kill all running instances of mpd_notify
# pkill mpd_notify.sh

# set initial value
oldname=$(mpc current)

# replace artist name with "various" if it's too long
function artist() {
	IFS='-' 
	read -ra ADDR<<<"$1"
	
	if [ "$(echo ${ADDR[0]} | wc -c)" -gt 10 ]; then
		echo "Various"
	else
		echo "${ADDR[0]}"
	fi
}

function song() {
	IFS='-'
	read -ra ADDR<<<"$1"

	echo "${ADDR[1]}"
}

function send_notif() {
	notify-send \
		--app-name="Music" \
		-h string:bgcolor:#333333 "$@"
}

while "true"; do
	# wait for a player event in mpc
	mpc idle player > /dev/null

	# if mpc current is empty and oldname is not
	# it means that this is the first time mpc current is empty
	# so send notif
	if [[ -z $(mpc current) ]] && [[ -n "$oldname" ]]; then
		# set oldname to mpc current so it won't trigger more than once
		oldname=$(mpc current)
		send_notif "Stopped playing"
	fi

	# if oldname does not match mpc current and mpc current len > 0,
	# it means that a song has just started playing
	# so send notif
	if [[ "$oldname" != "$(mpc current)" ]] && [[ -n "$(mpc current)" ]]; then
		oldname=$(mpc current)
		current=$(mpc current)
		#artist $current
		#song $current
		
		send_notif "Now playing:" "$current"
	fi

done
