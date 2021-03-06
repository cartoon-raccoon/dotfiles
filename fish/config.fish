set -x EDITOR (which nvim)
set -x PATH "$HOME/.cargo/bin/:$PATH"

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

alias ls="exa -l"
#alias fucking="sudo"
#alias pls="sudo"

alias fishreload="source ~/.config/fish/config.fish"

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

alias raccoonpi="ssh alarm@192.168.79.2"
alias raccoonpi-out="ssh alarm@cartoonraccoon.ddnsgeek.com -p 42169"

alias up="cd .."
alias up2="cd ../../"
alias up3="cd ../../../"
alias up4="cd ../../../../"
alias up5="cd ../../../../../"

alias icccm="curl www.call-with-current-continuation.org/rants/icccm.txt"
# opam configuration
source /home/sammy/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true
