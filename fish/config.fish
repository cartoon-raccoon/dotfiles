#set -x EDITOR (which nvim)

#set -x PATH "$HOME/.cargo/bin/:$HOME/.local/share/gem/ruby/3.0.0/bin:$HOME/.local/bin/cross/bin:$PATH"

#set -x LD_LIBRARY_PATH "$LD_LIBRARY_PATH:/usr/lib/jvm/default/lib/server/"

# set -x QT_QPA_PLATFORMTHEME "qt5ct"

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
	curl cheat.sh/$argv[1]
end

#export MPC_FORMAT='%artist%: %title% \[%album%\]'

alias ls="exa -l"
#alias fucking="sudo"
#alias pls="sudo"

alias fishreload="source ~/.config/fish/config.fish"

alias tlmgr="/usr/share/texmf-dist/scripts/texlive/tlmgr.pl --usermode $argv"

alias cavaconf="$EDITOR ~/.config/cava/config"
alias picomconf="$EDITOR ~/.config/picom/picom.conf"

alias alacconf="$EDITOR ~/.config/alacritty/alacritty.yml"
alias fishconf="$EDITOR ~/.config/fish/config.fish"
alias i3config="$EDITOR ~/.config/i3/config"
alias polyconf="$EDITOR ~/.config/polybar/config"

alias xmonadconf="$EDITOR ~/.xmonad/xmonad.hs"
alias xmobarconf="$EDITOR ~/.config/xmobar/xmobarrc"

alias spectrconf="$EDITOR ~/.spectrwm.conf"
alias baraction="$EDITOR ~/.config/bar_action.sh"

alias qtileconf="$EDITOR ~/.config/qtile/config.py"

alias raccoonpi="ssh ubuntu@192.168.79.2"
alias raccoonpi-out="ssh ubuntu@cartoonraccoon.ddnsgeek.com -p 42169"

alias ip="ip -c=always"

alias "angrtivate"="source ~/Projects/angr/bin/activate.fish"
# alias "deangrtivate"="~/Projects/angr/bin/deactivate"

alias up="cd .."
alias up2="cd ../../"
alias up3="cd ../../../"
alias up4="cd ../../../../"
alias up5="cd ../../../../../"

alias reset-bkgd="feh --bg-fill $DESKTOP_BKGD"

alias hexedit="hexedit --color"

alias icccm="curl www.call-with-current-continuation.org/rants/icccm.txt"
# opam configuration
# source /home/sammy/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true
