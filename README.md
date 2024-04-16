# dotfiles

Welcome to my dotfile repository! This repo contains the configuration files for every app that has existed or currently exists on my system.

Each directory contains the dotfiles and other scripts used for running the apps on my system.

## Dependencies

- Wayland Compositors:
  - Hyprland (Waybar) [Active]
  - Qtile (builtin bar)
- X11 WMs (Bar):
  - XMonad (xmobar)
  - Spectrwm (bar_action.sh)
  - i3-gaps (polybar)
  - Qtile (builtin bar)
- X Compositor: `picom`
- Notifications: `dunst`
- Shell: `fish`
- Terminals:
  - `alacritty` [Active]
  - `kitty`
- Music: `ncmpcpp`
- Editor: `nvim`
- Screenshot:
  - `grim`
  - `scrot`
- Other apps: `cava`, `scrot`, `spotify`, `feh`, `i3lock`, etc.

## Other Scripts

- `spotify/spotify-dbus.sh`: Uses dbus to send mpris2 player methods to control spotify. Bound to keybinds inside the WM config files. Not currently used, superseded by `playerctl`.
- `scrot/run.sh`: A script to take screenshots. Bound to keybinds. Not currently used in favour of `grim`.
- `mpd/mpd_notify.sh`: A script to throw up a desktop notification whenever MPD changes song.
Started automatically by the WM.
- `spectrwm/bar_action.sh` (Inactive): Generates bar contents for `spectrwm`.
- `autorandr/postswitch` (Inactive): A hook script run by autorandr when it is invoked. It runs `feh` to reset the desktop background and `i3lock-bkgd` to regenerate the lockscreen background. Not currently active, as I no longer use X11.
- `lightdm/profile` (Inactive): A profile script sourced by LightDM on login. It starts the global authenticator and runs `autorandr` to set the appropriate RandR config.
- `i3/{i3lock, i3lock-bkgd.py}` (Inactive): A script to run `i3lock` configured, and a Python script to automatically regenerate the lock screen background according to display setup.
- `qtile/autostart.sh`: Qtile startup script.
- `fish/pridefetch`: A python script called in `fish_greeting` to display a pride flag and relevant system infromation. Credit to [megabytesofrem/pridefetch](https://github.com/megabytesofrem/pridefetch) on GitHub.

## Bootstrap script

- strap.sh: a Bash script to setup an entire system from a base install.
  Currently heavily tailored to my system, but it will eventually be able to be dynamically configured at runtime for a general use case.
  It's so ridiculously over-engineered it's absurd, and I absolutely adore it.
  
  Run `./strap.sh -h` for the manual.

## Todo

- Set up DPMS and `xss-lock` to dim the screen before locking
- Convert `mpd_notify.sh` to a C program using `lib{mpdclient,notify}`
