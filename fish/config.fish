#set -x EDITOR (which nvim)

#set -x PATH "$HOME/.cargo/bin/:$HOME/.local/share/gem/ruby/3.0.0/bin:$HOME/.local/bin/cross/bin:$PATH"

#set -x LD_LIBRARY_PATH "$LD_LIBRARY_PATH:/usr/lib/jvm/default/lib/server/"

set -x CHEAT_PATH "$HOME/.cheat"
env | grep EDITOR > /dev/null || set -x EDITOR (which nvim)

# mpc functions
function mpcload
	mpc clear > /dev/null
	mpc load $argv[1]
end

function mpcplay
	mpcload $argv[1] > /dev/null
	mpc play
end

function mpcsave
	mpc rm $argv[1]
	mpc save $argv[1]
end

alias mpcls="mpc lsplaylists"

# package management functions
function addpkg
	sudo pacman -S $argv
end

function gimme
	sudo pacman -S $argv
end

function yeet
	sudo pacman -Rs $argv
end

function miniyeet
	sudo pacman -R $argv
end

function pkgquery
	pacman -Qi $argv
end

function pkgcount
	pacman -Q | wc -l
end

function xephyr
	Xephyr -br -ac -noreset -screen $argv
end

function cheat
	if not [ -e $CHEAT_PATH ]
		mkdir $CHEAT_PATH
	end

	if not [ -e $CHEAT_PATH/$argv[1] ]
		curl --silent cheat.sh/$argv[1] | tee $CHEAT_PATH/$argv[1]
		# delete file we just tee'd if command doesn't exist
		if grep 'Unknown topic' $CHEAT_PATH/$argv[1] > /dev/null
			rm $CHEAT_PATH/$argv[1]
		end
	else
		cat $CHEAT_PATH/$argv[1]
	end
end

function clear
	/usr/bin/clear
	fish_greeting
end

function newproj
	cd ~/Projects
	mkdir $argv
	cd $argv[1]
end

# set -g theme_color_scheme nord
# set -g theme_newline_prompt '> '
# set -g theme_newline_cursor yes

#export MPC_FORMAT='%artist%: %title% \[%album%\]'

alias ls="eza -l"
#alias fucking="sudo"
#alias pls="sudo"

alias fishreload="source ~/.config/fish/config.fish"

alias tlmgr="/usr/share/texmf-dist/scripts/texlive/tlmgr.pl --usermode $argv"

alias cavaconf="$EDITOR ~/.config/cava/config"

alias alacconf="$EDITOR ~/.config/alacritty/alacritty.toml"
alias fishconf="$EDITOR ~/.config/fish/config.fish"
alias hyprconf="$EDITOR ~/.config/hypr/hyprland.conf"
alias wayconf="$EDITOR ~/.config/waybar/config.jsonc"
alias pacconf="sudo $EDITOR /etc/pacman.conf"
alias duckconf="python ~/Projects/duckyPad-Config/duckypad_config.py"

alias xmonadconf="$EDITOR ~/.xmonad/xmonad.hs"
alias xmobarconf="$EDITOR ~/.config/xmobar/xmobarrc"

alias qtileconf="$EDITOR ~/.config/qtile/config.py"

alias raccoonpi="ssh ubuntu@192.168.79.2"
alias raccoonpi-out="ssh ubuntu@cartoonraccoon.ddnsgeek.com -p 42169"
alias hyprsock1="nc -U /$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock"
alias hyprsock2="nc -U /$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

alias ip="ip -c=always"
alias anglais="LANG=en_CA $argv"

alias "angrtivate"="source ~/Projects/angr/bin/activate.fish"
# alias "deangrtivate"="~/Projects/angr/bin/deactivate"``

alias up="cd .."
alias up2="cd ../../"
alias up3="cd ../../../"
alias up4="cd ../../../../"
alias up5="cd ../../../../../"

alias cdunit="~/Documents/School Stuff/University"
alias cdcourse="~/Documents/School\ Stuff/University/Courses/$argv[1]"

alias dskentry="sudo find /usr -iname $argv[1].desktop"

alias reset-bkgd="feh --bg-fill $DESKTOP_BKGD"

alias hexedit="hexedit --color"

alias icccm="curl www.call-with-current-continuation.org/rants/icccm.txt"
# opam configuration
# source /home/sammy/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true
