# dotfiles

Welcome to my dotfile repository! This repo contains the configuration files for every app that has existed or currently exists on my system.

Each directory contains the dotfiles and other scripts used for running the apps on my system.

## Dependencies

- Wayland Compositors:
  - Hyprland (Waybar) [Active]
  - Qtile (builtin bar)
- X11 Window Managers (Bar):
  - XMonad (xmobar)
  - Spectrwm (bar_action.sh)
  - i3-gaps (polybar)
  - Qtile (builtin bar)
- X11 Compositor: `picom`
- Notifications: `dunst`
- Shell: `fish`
- Music Players:
  - `mpd` and `mpc`
  - `spotify` (`playerctl`)
- Terminals:
  - `alacritty` [Active]
  - `kitty`
- Music: `ncmpcpp`
- Editor: `neovim`
- Screenshots:
  - `grim/slurp`
  - `scrot`
- Other apps: each directory (except `packagelists`) is the name of its corresponding application, so to use its config you'll need to have that installed (duh).

## Package Lists

Lists of packages to install are found in the `packagelists/` directory.

## Other Scripts

- `qtile/autostart.sh`: Qtile startup script. There is a wayland variant as well, affixed `_wl`. X11 variant not currently used, for obvious reasons.
- `waybar/launch_waybar.sh`: A wrapper script that launches Waybar and sets up `inotify` file watchers to restart Waybar whenever its config file or stylesheet is modified.
- `gammastep/gammastep.sh`: A wrapper script that pulls local coordinates based on IP address from `ipinfo.io` and runs `gammastep`, an app that adjusts display gamma based on time of day. Requires `curl` and `jq`.
- `grim/grim.sh`: A wrapper script that runs `grim/slurp` to take screenshots, either of a selected output, window, or region, and to either copy that to a clipboard, or to a file. Supersedes `scrot/run.sh`.
- `mpd/mpd_notify.sh`: A script to throw up a desktop notification whenever MPD changes song. Started automatically by the WM.
- `fish/pridefetch`: A python script called in `fish_greeting` to display a pride flag and relevant system infromation. Credit to [megabytesofrem/pridefetch](https://github.com/megabytesofrem/pridefetch) on GitHub.

### Inactive Scripts

Most inactive scripts are no longer used because they were either
superseded by a premade console command that did what I wanted, or because I no longer use its corresponding program (e.g. an X11 window manager).

- `spotify/spotify-dbus.sh`: Uses dbus to send mpris2 player methods to control spotify. Bound to keybinds inside the WM config files. Requires DBus and its related utilities. Not currently used, superseded by `playerctl`.
- `scrot/run.sh`: A script to take screenshots. Bound to keybinds. No longer used, as `scrot` only works on X11.
- `spectrwm/bar_action.sh`: Generates bar contents for `spectrwm`.
- `autorandr/postswitch`: A hook script run by autorandr when it is invoked. It runs `feh` to reset the desktop background and `i3lock-bkgd` to regenerate the lockscreen background. 
- `lightdm/profile`: A profile script sourced by LightDM on login. It starts the global authenticator and runs `autorandr` to set the appropriate RandR config. Not currently active, as I now use SDDM.
- `i3/{i3lock, i3lock-bkgd.py}`: A script to run `i3lock` configured, and a Python script to automatically regenerate the lock screen background according to display setup.

## Bootstrap Script

- `strap.sh`: a Bash script to setup an entire system from a base install.
  Currently heavily tailored to my system, but it will eventually be able to be dynamically configured at runtime for a general use case.
  It's so ridiculously over-engineered it's absurd, and I absolutely adore it.
  
  Run `./strap.sh -h` for the manual.

## Todo

- Get GeoClue working so gammastep can depend on that
- Convert `mpd_notify.sh` to a C program using `lib{mpdclient,notify}`
