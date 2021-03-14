#!/bin/bash

# Colour variables - should always be followed by a semicolon
fgdef="+@fg=0"
fgwhite="+@fg=1"
fgred="+@fg=2"
fgyellow="+@fg=3"
fggreen="+@fg=4"
fgblue="+@fg=5"
fgorange="+@fg=6"
fgcyan="+@fg=7"
fgpurple="+@fg=8"

# Font variables - should always be followed by a semicolon
# Default english font (Fira Code Nerd)
fneng="+@fn=0"
# Japanese font (Source Han Sans JP)
fnjap="+@fn=1"

## Date
dte() {
	dte="$(date +"%A, %B %d %l:%M%p")"
	echo -e "$fgwhite;$dte$fgdef;"
}

## SSD
ssd() {
	ssd="$(df /home -h | awk 'NR==2{print $3, $5}')"
	echo -e "$fgblue; /home: $fgdef;$ssd"
}

## MEM
mem() {
	mem="$(free -h | awk 'NR==2{print $3, $7}')"
	echo -e "$fgcyan;  : $fgdef;$mem"
}

## CPU
cpu() {
	read cpu a b c previdle rest < /proc/stat
	prevtotal=$((a+b+c+previdle))
	sleep 0.5
	read cpu a b c idle rest < /proc/stat
	total=$((a+b+c+idle))
	cpu=$((100*( (total-prevtotal) - (idle-previdle) ) / (total-prevtotal) ))
	echo -e "$fgred; : $fgdef;$cpu%"
}

## BATT
batt() {
	finalstat="?"
	read status < /sys/class/power_supply/BAT0/status
	if [[ "$status" == "Discharging" ]]; then
		finalstat="D"
	elif [[ "$status" == "Charging" ]]; then
		finalstat="C"
	elif [[ "$status" == "Full" ]]; then
		finalstat="F"
	fi

	read batt < /sys/class/power_supply/BAT0/capacity
	echo -e "$fgyellow;   : $fgdef;$batt% ($finalstat)"
}


## MPD
mpdck() {
	# getting current song
	mpdcurrent="$(mpc current)"

	# truncating song name to fit status bar
	trunc=${mpdcurrent:0:30} 

	# appending ellipsis if truncated
	finalcurr="$trunc"
	if [[ "$mpdcurrent" != "$trunc" ]]; then
		finalcurr="$finalcurr..."
	fi

	# getting song data (timestamp)
	mpdtime="$(mpc status | awk 'NR==2{print $3, $4}')"
	
	# outputting song
	# if mpd current is empty
	if [[ -z $mpdcurrent ]]; then
		echo -e "Nothing playing"
	else
		# testing if current string is entirely ascii
		if [[ $mpdcurrent = *[![:ascii:]]* ]]; then
			# if no, switch to jap font when printing title
			echo -e "$fgorange; Music: $fgdef;$fnjap; $finalcurr  $fneng;[$mpdtime]"
		else
			# else nothing to worry about
			echo -e "$fgorange; Music: $fgdef;$finalcurr [$mpdtime]"
		fi
	fi
}

while "true"; do
	echo "$(dte) | $(ssd) | $(mem) | $(cpu) | $(batt) | $(mpdck)"
	sleep 1
done
