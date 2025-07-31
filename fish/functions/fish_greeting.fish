function fish_greeting
	if [ $TERM != "xterm-256color" ];
		echo ">>>>>" (tput bold)It is (tput setaf 178)(date '+%I:%M %p')(tput setaf 252) on (tput setaf 167)(date '+%A, %d %B %G')(tput sgr0) '<<<<<'
		echo ""
		fastfetch --logo ~/.config/fastfetch/logo -c ~/.config/fastfetch/config_termstart.jsonc
		echo ""
		fortune -s -n 300 | fmt -85 | lolcat -F 0.4
		echo "========================================================================================"
	end
end
