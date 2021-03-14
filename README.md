# dotfiles
Currently juggling the dotfiles of 3 WMs: XMonad, Spectrwm, and i3-gaps. More coming soon.

Each directory contains the dotfiles and other scripts used for running the apps on my system.

## Dependencies
- WMs (Bar):
	- XMonad (xmobar)
	- Spectrwm (bar_action.sh)
	- i3-gaps (polybar)
- Compositor: `picom`
- Notifications: `dunst`
- Shell: `fish`
- Terminal: `alacritty`
- Music: `ncmpcpp`
- Editor: `Neovim`
- Other apps: `cava`, `scrot`, `spotify`, `feh`

## Other scripts
- spotify/spotify-dbus.sh: Uses dbus to send mpris2 player methods to control spotify. Bound to keybinds inside the WM config files.
- scrot/run.sh: A script to take screenshots. Bound to keybinds.
