# dotfiles

Currently juggling the dotfiles of 4 WMs: Qtile, XMonad, Spectrwm, and i3-gaps. More coming soon.

_Shameless self-plug: I'm working on my own window manager [here](https://github.com/cartoon-raccoon/rcwm)._

Each directory contains the dotfiles and other scripts used for running the apps on my system.

## Dependencies

- WMs (Bar):
  - XMonad (xmobar)
  - Spectrwm (bar_action.sh)
  - i3-gaps (polybar)
  - Qtile (builtin bar)
- Compositor: `picom`
- Notifications: `dunst`
- Shell: `fish`
- Terminal: `alacritty`
- Music: `ncmpcpp`
- Editor: `Neovim`
- Other apps: `cava`, `scrot`, `spotify`, `feh`, `i3lock`, etc.

## Other scripts

- spotify/spotify-dbus.sh: Uses dbus to send mpris2 player methods to control spotify. Bound to keybinds inside the WM config files.
- scrot/run.sh: A script to take screenshots. Bound to keybinds.

## Bootstrap script

- strap.sh: a script to setup an entire system from a base install.
  Currently only the installation phase is implemented, linking not yet.
