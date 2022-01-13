#!/bin/bash

# strap.sh: A ridiculously over-engineered Arch Linux bootstrap script.
# It's probably one of the best pieces of software I've ever written.
# This software is dual-licensed under the Unlicense and the WTFPL.
# Copyright (c) 2021 cartoon-raccoon

# todo:
# - add verbose output
# - improve coloured messages
#   - add different indicators for different actions
#   - e.g. [*] for info, ==> for major actions
# - implement post-link hooks
# - implement pre and post-install hooks
# - move all user-specific config out of the source into a config.sh file
#   - i.e. link_dirs

# Start!
function init() {
    say '
      _                              _
 ___ | |_  _ __  __ _  _ __     ___ | |__
/ __|| __||  __|/ _` ||  _ \   / __||  _ \
\__ \| |_ | |  | (_| || |_) |_ \__ \| | | |
|___/ \__||_|   \__,_|| .__/(_)|___/|_| |_|
                      |_|
'
    say "./strap.sh v0.1.0"
    say "(c) 2021 cartoon-raccoon"
    # info ""

    # Check whether OS is Arch
    [[ -e /etc/os-release ]] \
        || fail "[!] Cannot find os-release file, aborting!" 1

    grep "Arch Linux" < /etc/os-release > /dev/null \
    	|| fail "[!] Unsupported OS, aborting!" 2
    
    # Check whether git is installed
    pacman -Q git > /dev/null \
        || fail "[!] Git not installed, aborting!"

    trap on_ctrlc SIGINT
}

function print_help() {
    info "./strap.sh - a ridiculously over-engineered Arch Linux bootstrap script.

strap.sh is a bash script for bootstrapping my (cartoon-raccoon's) Arch Linux
system. It is designed to be run from inside my dotfiles git repo, and sets up
the entire system from a base Arch install.

strap.sh has three main phases: first, it sources a package list and installs all 
the requisite packages. Next, it hooks up dotfiles to the appropriate directory 
in the user's home directory, by symlinking, copying or moving the file, and
lastly runs systemctl to enable the relevant system services (in my case, MPD and
my display manager).

After each phase, strap.sh can run hooks to perform user-specific behaviour. These
hooks are sourced from a hooks file and allow the user to perform specific actions
for various special cases.

strap.sh is heavily tailored to my own Arch Linux setup. Use at your own risk!

USAGE: ./strap.sh [SUBCOMMAND] [-irsdev] [OPTIONS]

SUBCOMMANDS:

    full:    Does everything. Installs all the required packages, and then links
             the dotfiles with the specified action.
             Defaults to this if no subcommand is specified.

    install: Only installs packages. Does not do dotfile linking. Useful if you
             want to configure the system yourself.

    link:    Only links the dotfiles. Nothing is installed.

FLAGS:

    --interactive/-i: Prompt the user for yes/no when (re)installing packages.
                      Does not affect AUR package installation; installation of
                      AUR packages is always interactive.

    --reinstall/-r:   By default, strap.sh does not reinstall packages that
                      are already in the system. Using this option forces it
                      to reinstall the package.

    --no-sysctl/-s:   After the installation phase, do not enable system services.
    
    --dry-run/-d:     Enables dry-run mode. The script will run through the entire
                      bootstrap sequence, but the actual installation and linking
                      will not be carried out.

    --essential/-e:   Only install essential apps that the dotfiles rely on.
                      This does NOT install base dependencies like the X server,
                      pulseaudio, ALSA, graphics drivers, etc. and assumes that
                      you already have them installed. Use with caution. 
    
    --verbose/-v:     Do not redirect installation output to /dev/null.
                      Does not affect full upgrades (pacman -Syu) and installing
                      AUR packages.
    
OPTIONS:

    --action/-a [link|copy|move]: 

    The action to take when linking to dotfiles to their respective directories.
    Link creates soft links inside the destination directory, but the actual files
    remain inside the repository.
    Copy copies the files, and move moves the files to their respective directories.
    Defaults to link.

    --display-manager/-dm [lightdm|sddm]:

    The display manager to install. Can be LightDM (default), or SDDM.

    --window-manager/-wm [all|xmonad|qtile|spectrwm|i3]:

    The window manager to install. Can be all four (default), or xmonad, spectrwm, 
    qtile or i3-gaps only.
    Note: this will only prevent installation of the WM itself. Any packages associated
    with the WM (e.g. xmobar + xmonad-contrib with xmonad) will still be installed.
    
    --aur-helper/-ah [paru|yay|pacaur]:

    The AUR helper to install. Can be paru (default), yay or pacaur. By default,
    install installs the bin version of the helper, so as to avoid downloading more
    dependencies and compilation times (paru requires cargo, yay requires go).

    --hooks/-hk [FILE]:

    The hooks file to source from. Defaults to hooks.sh.
"
}

#* oo.ooooo.   .oooo.   oooo d8b  .oooo.   ooo. .oo.  .oo.    .oooo.o 
#*  888' `88b `P  )88b  `888""8P `P  )88b  `888P"Y88bP"Y88b  d88(  "8 
#*  888   888  .oP"888   888      .oP"888   888   888   888  `"Y88b.  
#*  888   888 d8(  888   888     d8(  888   888   888   888  o.  )88b 
#*  888bod8P' `Y888""8o d888b    `Y888""8o o888o o888o o888o 8""888P' 
#*  888                                                               
#* o888o    

##### Default parameters #####

declare -A params=(
    [subcommand]="full"
    [interactive]=false
    [reinstall]=false
    [sysctl]=true
    [dryrun]=false
    [essential]=false
    [verbose]=false
    [action]="link"
    [displaym]="lightdm"
    [windowm]="all"
    [helper]="paru"
)

# aur urls of aur helpers
declare -Ar helper_urls=(
    [paru]="https://aur.archlinux.org/packages/paru-bin.git"
    [yay]="https://aur.archlinux.org/packages/yay-bin.git"
    [pacaur]="https://aur.archlinux.org/packages/pacaur.git"
)

# dotfile repo directory
declare -r REPO_DIR=$PWD

##### Short Argument Parsing #####

# bug: this cannot account for unknown flags
function parse_short_toggle_args() {
    interactive "$1"
    reinstall "$1"
    sysctl "$1"
    dry_run "$1"
    essential "$1"
    verbose "$1"

    # if [[ $1 = (^-irslev) ]]; then
    #     info "Unknown flag"
    #     exit 1
    # fi
}

function interactive() {
    if [[ $1 = *i* ]]; then
        params[interactive]=true
    fi
}

function reinstall() {
    if [[ $1 = *r* ]]; then
        params[reinstall]=true
    fi
}

function sysctl() {
    if [[ $1 = *s* ]]; then
        params[sysctl]=false
    fi
}

function dry_run() {
    if [[ $1 = *d* ]]; then
        params[dryrun]=true
    fi
}

function essential() {
    if [[ $1 = *e* ]]; then
        params[essential]=true
    fi
}

function verbose() {
    if [[ $1 = *v* ]]; then
        params[verbose]=true
    fi
}

##### Valued Argument Parsing #####

function parse_valued_args() {
    case $1 in
    window-manager)
        params[windowm]="$2"
        ;;
    display-manager)
        params[displaym]="$2"
        ;;
    aur-helper)
        params[helper]="$2"
        ;;
    action)
        case $2 in
        ln|link)
            params[action]="link"
            ;;
        cp|copy)
            params[action]="copy"
            ;;
        mv|move)
            params[action]="move"
           ;;
        *)
            fail "strap.sh: unsupported dotfile action: $2" 2
            ;;
        esac
        ;;
    *)
        fail "strap.sh: unknown perimeter $1" 2
        ;;
    esac
}

##### Parsing Driver Function #####

function parse_args() {

    # parsing subcommand
    case $1 in
    full)
        params[subcommand]="full"
        shift
        ;;
    install)
        params[subcommand]="install"
        shift
        ;;
    link)
        params[subcommand]="link"
        shift
        ;;
    -?)
        params[subcommand]="full"
        ;;
    ?)
        fail "strap.sh: Unknown subcommand '$1'" 2
        ;;
    esac

    # when it encounters a valued flag
    state=""
    # index in the argument vector
    local idx=1

    for arg in "$@"; do
        case $arg in
        -h|--help)
            print_help
            exit
            ;;
        -wm|--window-manager)
            check_missing_value "$state"
            state="window-manager"
            continue
            ;;
        -dm|--display-manager)
            check_missing_value "$state"
            state="display-manager"
            continue
            ;;
        -ah|--aur-helper)
            check_missing_value "$state"
            state="aur-helper"
            continue
            ;;
        -a|--action)
            check_missing_value "$state"
            state="action"
            continue
            ;;
        --interactive)
            check_missing_value "$state"
            params[interactive]=true
            ;;
        --reinstall)
            check_missing_value "$state"
            params[reinstall]=true
            ;;
        --no-sysctl)
            check_missing_value "$state"
            params[sysctl]=false
            ;;
        --dry-run)
            check_missing_value "$state"
            params[dryrun]=true
            ;;
        --essential)
            check_missing_value "$state"
            params[essential]=true
            ;;
        --verbose)
            check_missing_value "$state"
            params[verbose]=true
            ;;
        --*)
            fail "strap.sh: unknown parameter '$arg'" 1
            ;;
        -*)
            check_missing_value "$state"
            parse_short_toggle_args "$arg"
            ;;
        *)
            parse_valued_args "$state" "$arg"
            ;;
        esac

        state=""

        idx=$(( idx + 1 ))

    done

    check_missing_value "$state"
    _check_values
}

function _check_values() {

    # checking helper
    case ${params[helper]} in
    paru|yay|pacaur)
        ;;
    *)
        fail "strap.sh: unrecognized AUR helper: ${params[helper]}" 2
        ;;
    esac

    # checking display manager
    case ${params[displaym]} in
    lightdm|sddm)
        ;;
    *)
        fail "strap.sh: unsupported display manager: ${params[displaym]}" 2
        ;;
    esac

    # checking window manager
    case ${params[windowm]} in
    xmonad|i3-gaps|spectrwm|qtile|all)
        ;;
    *)
        fail "strap.sh: unsupported window manager: ${params[windowm]}" 2
        ;;
    esac

    case ${params[action]} in
    link|copy|move|ln|cp|mv)
        ;;
    *)
        fail "strap.sh: unrecognized dotfile action: ${params[action]}" 2
        ;;
    esac
}

function confirm() {
    printf "\n${format[bold]}SUMMARY OF ACTIONS:${colors[reset]}\n\n"
    printf "Subcommand: %s\n\n" "${params[subcommand]}"
    printf "Behaviour:\n"
    printf "interactive mode:   %s\n" "${params[interactive]}"
    printf "do reinstallation:  %s\n" "${params[reinstall]}"
    printf "enable services:    %s\n" "${params[sysctl]}"
    printf "install essentials: %s\n" "${params[essential]}"
    printf "verbose mode:       %s\n" "${params[verbose]}"
    printf "dotfile action:     %s\n" "${params[action]}"

    printf "\nYour chosen core apps:\n"
    printf "Display Manager:    %s\n" "${params[displaym]}"
    printf "Window Manager(s):  %s\n" "${params[windowm]}"
    printf "AUR helper:         %s\n" "${params[helper]}"
    printf "\n"

    if ${params[essential]} && ! ${params[dryrun]}; then
        warn "WARNING: essential mode only installs APPLICATIONS.
It does not install base dependencies like the 
X server, pulseaudio, ALSA, graphics drivers, etc.
and assumes that you already have them installed."
    fi

    if ${params[dryrun]}; then
        warn "You have enabled dry-run mode. The script will now run through 
the entire sequence, but nothing will be installed, linked or enabled."
    fi
    
    ask "Do you want to continue? [Y/n] "
    
    if ! get_user_choice; then
        info "Exiting!"
        exit 0
    fi

    say "Proceeding with bootstrap."
    # info ""
}

#*  o8o                           .             oooo  oooo  
#*  `"'                         .o8             `888  `888  
#* oooo  ooo. .oo.    .oooo.o .o888oo  .oooo.    888   888  
#* `888  `888P"Y88b  d88(  "8   888   `P  )88b   888   888  
#*  888   888   888  `"Y88b.    888    .oP"888   888   888  
#*  888   888   888  o.  )88b   888 . d8(  888   888   888  
#* o888o o888o o888o 8""888P'   "888" `Y888""8o o888o o888o 

# The main install function.
function install_all() {
    say  '----------| Installation |----------'
    info 'Running full system upgrade:'
    echo ""

    if ! ${params[dryrun]}; then
        sudo pacman -Syu --noconfirm || fail "[!] Error on system upgrade, aborting." 1
    else
        info "Dry run, skipping upgrade."
    fi
    # info ""

    info "Installing AUR helper ${params[helper]}:"
    say  "=========================================="
    local helper_bin=""
    if [[ "${params[helper]}" = "pacaur" ]]; then
        local helper_bin="pacaur"
    else
        local helper_bin="${params[helper]}-bin"
    fi
     
    if ! pacman -Q ${params[helper]} > /dev/null 2>&1 \
    || ! pacman -Q $helper_bin > /dev/null 2>&1; then
        install_helper
    else 
        info "Helper $helper_bin is already installed."
    fi

    if ! [[ -e fullpackagelist ]] || ! [[ -e esspackagelist ]]; then
        fail "[!] Cannot find package list required for install - Aborting!" 1
    fi

    info "Installing packages from package list:"
    say  "=========================================="

    if ${params[essential]}; then
        packagelist=$(cat esspackagelist)
    else
        packagelist=$(cat fullpackagelist)
    fi

    install_driver
}

function install_helper() {
    local url=${helper_urls[${params[helper]}]}
    local helper=${params[helper]}

    cd ..

    info "Cloning into $helper..."
    dryrunck && say "git clone $url"
    info "cd'ed into $helper-bin..."
    info "running makepkg..."

    dryrunck && say "makepkg -si"

    cd $REPO_DIR || fail "Directory $REPO_DIR does not exist." 1
}

# drives the entire install process
function install_driver() {
    local wm="${params[windowm]}"
    local dm="${params[displaym]}"

    if [[ "$wm" != "all" ]]; then
        install_check $wm
    fi

    install_check $dm

    for package in $packagelist; do
        if [[ "$package" = "xmonad" ]]\
        || [[ "$package" = "i3-gaps" ]]\
        || [[ "$package" = "qtile" ]]\
        || [[ "$package" = "spectrwm" ]]\
        || [[ "$package" = "lightdm" ]]\
        || [[ "$package" = "sddm" ]]; then
            if [[ "$wm" != "all" ]]; then
                continue
            fi
        fi
        install_check "$package"
    done
}

# check if a package is already installed
# and take action according to whether reinstall is enabled
function install_check() {
    if pacman -Q "$1" > /dev/null 2>&1; then
        say -n "$1 is already installed."
        if ${params[reinstall]}; then
            install_pkg "$1" true
        else
            say " Skipping..."
            return 0
        fi
    else
        install_pkg "$1" false
    fi
}

# ask the user if they would like to reinstall
function install_pkg() {
    # is reinstall
    if $2; then
        if ${params[interactive]}; then
            ask " Would you like to reinstall? [Y/n] "
            get_user_choice || return 0
        fi
        info "Reinstalling package $1..."
        if ! ${params[dryrun]}; then
            _install "$1"
        fi
    else
        if ${params[interactive]}; then
            ask "Install $1? [Y/n] "
            get_user_choice || return 0
        fi
        info "Installing package $1..."
        if ! ${params[dryrun]}; then
            _install $1
        fi
    fi
}

# actually handles the install
function _install() {
    local pkg=$1
    local helper=${params[helper]}

    # always interactive
    #todo: implement check for why it failed 
    if ! sudo pacman -S --noconfirm "$pkg"; then
        # info ""
        info "$pkg not found with pacman, using $helper instead."
        $helper -S "$pkg" 
    fi
    return 0
}

#* oooo   o8o              oooo         o8o                         
#* `888   `"'              `888         `"'                         
#*  888  oooo  ooo. .oo.    888  oooo  oooo  ooo. .oo.    .oooooooo 
#*  888  `888  `888P"Y88b   888 .8P'   `888  `888P"Y88b  888' `88b  
#*  888   888   888   888   888888.     888   888   888  888   888  
#*  888   888   888   888   888 `88b.   888   888   888  `88bod8P'  
#* o888o o888o o888o o888o o888o o888o o888o o888o o888o `8oooooo.  
#*                                                       d"     YD  
#*                                                       "Y88888P'  

declare -r CONFIG_DIR="$HOME/.config"
declare -r HOME_DIR="$HOME"

# list of dest and source files
# key: dest file
# value: src file

# Add directories as needed.
declare -Ar linkdirs=(
    ["$CONFIG_DIR/alacritty/alacritty.yml"]="alacritty/alacritty.yml"
    ["$CONFIG_DIR/cava/config"]="cava/config"
    ["$CONFIG_DIR/dunst/dunstrc"]="dunst/dunstrc"
    ["$CONFIG_DIR/fish/config.fish"]="fish.config.fish"
    ["$CONFIG_DIR/i3/config"]="i3/config"
    ["$CONFIG_DIR/i3/i3lock"]="i3/i3lock"
    ["$CONFIG_DIR/mpd/mpd.conf"]="mpd/mpd.conf"
    ["$CONFIG_DIR/mpd/mpd_notify.sh"]="mpd/mpd_notify.sh"
    ["$CONFIG_DIR/ncmpcpp/config"]="ncmpcpp/config"
    ["$CONFIG_DIR/nvim/init.vim"]="nvim/init.vim"
    ["$CONFIG_DIR/picom/picom.conf"]="picom/picom.conf"
    ["$CONFIG_DIR/polybar/config"]="polybar/config"
    ["$CONFIG_DIR/qtile/autostart.sh"]="qtile/autostart.sh"
    ["$CONFIG_DIR/config.py"]="qtile/config.py"
    ["$CONFIG_DIR/scrot/run.sh"]="scrot/run.sh"
    ["$HOME_DIR/.spectrwm.conf"]="spectrwm/.spectrwm.conf"
    ["$CONFIG_DIR/spectrwm/bar_action.sh"]="spectrwm/bar_action.sh"
    ["$CONFIG_DIR/spotify-dbus.sh"]="spotify/spotify-dbus.sh"
    ["$CONFIG_DIR/xmobar/xmobarrc"]="xmobar/xmobarrc"
    ["$CONFIG_DIR/xmonad/xmonad.hs"]="xmonad/xmonad.hs"
)

declare link_action=""

# handles the linking process
function link_all() {
    info "Starting linking"

    set_link_action

    for dest in "${!linkdirs[@]}"; do
        local src=${linkdirs[$dest]}
        say "Linking $src to $dest..."
        if ! ${params[dryrun]}; then
            mkdir -p $(dirname "$dest") 
            $link_action "$src" "$dest"
        fi
    done

    run_link_hooks
}

# sets the link action based on parameters given
function set_link_action {
    case ${params[action]} in
    link)
        link_action="ln -s"
        ;;
    copy)
        link_action="cp"
        ;;
    move)
        link_action="mv"
        ;;
    esac
}

# run any user-defined post-link hooks
function run_link_hooks {
    true
}

#*                 .    o8o  oooo  
#*               .o8    `"'  `888  
#* oooo  oooo  .o888oo oooo   888  
#* `888  `888    888   `888   888  
#*  888   888    888    888   888  
#*  888   888    888 .  888   888  
#*  `V88V"V8P'   "888" o888o o888o 

##### Helper functions ##### 
function ask() {
    printf "%s" "$1"
}

function say() {
    if [[ "$1" = "-n" ]]; then  
        printf "%s"   "$2"
    else
        printf "%s\n" "$1"
    fi
}

function info() {
    printf "${format[bold]}${colors[green]}[*]${colors[reset]} %s\n" "$1"
}

function warn() { 
    printf "${format[bold]}${colors[yellow]}[!]${colors[reset]} %s\n\n" "$1"
}

function fail() {
    printf "%s\n" "$1" >&2
    exit "$2"
}

function check_missing_value() {
    [[ -n "$1" ]] && fail "strap.sh: missing value for parameter $1" 2
}
 
function dryrunck() {
    ! ${params[dryrun]}
}

function get_user_choice() {
    read -r choice

    case $choice in
    y|yes|Y|Yes)
        return 0;
        ;;
    n|no|N|No)
        return 1;
        ;;
    *)
        fail "Unknown option: $choice" 2
        ;; 
    esac
}

function cleanup() {
    # info ""
    info "Cleaning up..."

    local orphans=$(pacman -Qqtd)
    if [[ -n $orphans ]] &&  ! ${params[dryrun]}; then
        sudo pacman -Rs --noconfirm $(pacman -Qqtd) \
            || fail "[!] Failed to clean orphaned packages."
    fi

    # info ""
    info "All done, enjoy your new system!"
} 

function on_ctrlc() { 
    info "\nSIGINT received, stopping!"

    exit 1
}

declare -Ar colors=(
    [black]="\u001b[30m" 
    [red]="\u001b[31m"
    [green]="\u001b[32m"
    [yellow]="\u001b[33m"
    [blue]="\u001b[34m"
    [magenta]="\u001b[35m" 
    [brblack]="\u001b[30;1m"
    [brred]="\u001b[31;1m"
    [brgreen]="\u001b[32;1m" 
    [bryellow]="\u001b[33;1m"
    [brblue]="\u001b[34;1m"
    [brmagenta]="\u001b[34;1m" 
    [reset]="\u001b[0m"
)

declare -Ar format=( 
    [bold]="\u001b[1m"
    [underline]="\u001b[4m"
    [reversed]="\u001b[7m"
)

#*                              o8o              
#*                              `"'              
#* ooo. .oo.  .oo.    .oooo.   oooo  ooo. .oo.   
#* `888P"Y88bP"Y88b  `P  )88b  `888  `888P"Y88b  
#*  888   888   888   .oP"888   888   888   888  
#*  888   888   888  d8(  888   888   888   888  
#* o888o o888o o888o `Y888""8o o888o o888o o888o 
                                              

##### The magic happens here. #####

function main() {
    parse_args "$@"
    init
    confirm

    if [[ "${params[subcommand]}" != "link" ]]; then
        install_all
    else    
        info "Skipping install."
    fi

    if [[ "${params[subcommand]}" != "install" ]]; then
        link_all
    else 
        info "Skipping linking."
    fi

    cleanup
}

# call main
main "$@"
 