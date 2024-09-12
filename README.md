# dotfiles

Welcome to my dotfile repository! This repo contains the configuration files for every app that has existed or currently exists on my system.

Each directory contains the dotfiles and other scripts used for running the apps on my system.

## Dependencies

- Wayland Compositors (Bar):
  - `hyprland` (`waybar`) [Active]
  - `qtile` (builtin bar)
  - `sway` (`waybar`)
- X11 Window Managers (Bar):
  - `xmonad` (`xmobar`)
  - `spectrwm` (bar_action.sh)
  - `i3-gaps` (`polybar`)
  - `qtile` (builtin bar)
- X11 Compositor: `picom`
- Login Manager:
  - `gdm` [Active]
  - `sddm`
  - `lightdm`
- Notifications: `dunst`
- Shell: `fish`
- Music Players:
  - `mpd` and `mpc`
  - `ncmpcpp`
  - `spotify` (`playerctl`)
- Terminals:
  - `alacritty` [Active]
  - `kitty`
- Editor: `neovim`
- Screenshots:
  - `grim/slurp`
  - `scrot`
- Other apps: each directory (except `packagelists`) is the name of its corresponding application, so to use its config you'll need to have that installed (duh).

## Installation

Generally, configuration files are placed in a directory with the path `~/.config/<app_name>`, but you should double-check on where the config file is placed for each individual application. To ensure that changes to the files are immediately reflected in this repository, you should create a symlink in the config directory that points to the corresponding file in this directory. There are some exceptions, however; `mpd` and `sddm` have their files placed into the root directory, so they should be copied instead.

## Package Lists

Lists of packages to install are found in the `packagelists/` directory.

## Other Scripts

- `qtile/autostart.sh`: Qtile startup script. There is a wayland variant as well, affixed `_wl`.
- `waybar/launch_waybar.sh`: A wrapper script that launches Waybar and sets up `inotify` file watchers to restart Waybar whenever its config file or stylesheet is modified.
- `gammastep/gammastep.sh`: A wrapper script that pulls local coordinates based on IP address from `ipinfo.io` and runs `gammastep`, an app that adjusts display gamma based on time of day. Requires `curl` and `jq`.
- `hypr/dimdisplay.sh`: A script to dim displays of both an external monitor and my laptop monitor.
- `hypr/workspaceswap.sh`: A script to swap workspaces across double monitors.
- `grim/grim.sh`: A wrapper script that runs `grim/slurp` to take screenshots on Wayland, either of a selected output, window, or region, and to either copy that to clipboard, or to a file.
- `scrot/run.sh`: A script to take screenshots on X11 in Qtile. Bound to keybinds.
- `mpd/mpd_notify.sh`: A script to throw up a desktop notification whenever MPD changes song. Started automatically by the window manager/compositor.
- `fish/pridefetch`: A python script called in `fish_greeting` to display a pride flag and relevant system infromation. Credit to [megabytesofrem/pridefetch](https://github.com/megabytesofrem/pridefetch) on GitHub.
- `i3/{i3lock, i3lock-bkgd.py}`: A script to run `i3lock` configured, and a Python script to automatically regenerate the lock screen background according to display setup. Used on Qtile sessions.
- `autorandr/postswitch`: A hook script run by autorandr when it is invoked. It runs `feh` to reset the desktop background and `i3lock-bkgd` to regenerate the lockscreen background.

### Inactive Scripts

Most inactive scripts are no longer used because they were either superseded by a premade console command that did what I wanted, or because I no longer use its corresponding program (e.g. an X11 window manager).

- `spotify/spotify-dbus.sh`: Uses dbus to send mpris2 player methods to control spotify. Bound to keybinds inside the WM config files. Requires DBus and its related utilities. Not currently used, superseded by `playerctl`.
- `spectrwm/bar_action.sh`: Generates bar contents for `spectrwm`, which I no longer use.
- `lightdm/profile`: A profile script sourced by LightDM on login. It starts the global authenticator and runs `autorandr` to set the appropriate RandR config. Not currently active, as I now use GDM.

## Bootstrap Script

- `strap.sh`: a Bash script to setup an entire system from a base install.
  Currently heavily tailored to my system, but it will eventually be able to be dynamically configured at runtime for a general use case.
  It's so ridiculously over-engineered it's absurd, and I absolutely adore it.
  
  Run `./strap.sh -h` for the manual.

## Todo

- Get GeoClue working so gammastep can depend on that
- Write script for duckyPad profile autoswitch
- Convert `mpd_notify.sh` to a C program using `lib{mpdclient,notify}`
