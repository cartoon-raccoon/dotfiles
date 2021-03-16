#!/bin/bash


# Start!
init() {
    echo '
      _                              _
 ___ | |_  _ __  __ _  _ __     ___ | |__
/ __|| __||  __|/ _` ||  _ \   / __||  _ \
\__ \| |_ | |  | (_| || |_) |_ \__ \| | | |
|___/ \__||_|   \__,_|| .__/(_)|___/|_| |_|
                      |_|
'
    echo "./strap.sh v0.1.0"
    echo "(c) 2021 cartoon-raccoon"
    echo ""

    # Check whether OS is Arch
    [[ -e /etc/os-release ]] \
        || fail "[!] Cannot find os-release file, aborting!" 1

    cat /etc/os-release | grep 'Arch Linux' > /dev/null \
        || fail "[!] Unsupported OS, aborting!" 2
}

print_help() {
    echo "./strap.sh - a program for bootstrapping an Arch Linux system

strap.sh is a bash script for bootstrapping my (cartoon-raccoon's) Arch Linux
system. It is designed to be run from inside my dotfiles git repo, and sets up
the entire system from a base Arch install.

strap.sh has two main phases: first, it installs all the requisite packages and
then runs systemctl to enable the relevant system services (in my case, MPD and
my display manager). next, it hooks up dotfiles to the appropriate directory in
the user's home directory, by symlinking, copying or moving the file.

strap.sh is heavily tailored to my own Arch Linux setup. Use at your own risk!

USAGE: ./strap.sh [-irslev] [OPTIONS]

FLAGS:

    --interactive/-i: Prompt the user for yes/no when (re)installing packages.
                      Does not affect AUR package installation; installation of
                      AUR packages is always interactive.

    --reinstall/-r:   By default, strap.sh does not reinstall packages that
                      are already in the system. Using this option forces it
                      to reinstall the package.

    --no-sysctl/-s:   After the installation phase, do not enable system services.
    
    --no-link/-l:     After installation, do not link dotfiles.

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

    --window-manager/-wm [all|xmonad|spectrwm|i3]:

    The window manager to install. Can be all three (default), or xmonad, spectrwm, 
    or i3-gaps.
    
    --aur-helper/-ah [paru|yay|pacaur]:

    The AUR helper to install. Can be paru (default), yay or pacaur.
"
}

# oo.ooooo.   .oooo.   oooo d8b  .oooo.   ooo. .oo.  .oo.    .oooo.o 
#  888' `88b `P  )88b  `888""8P `P  )88b  `888P"Y88bP"Y88b  d88(  "8 
#  888   888  .oP"888   888      .oP"888   888   888   888  `"Y88b.  
#  888   888 d8(  888   888     d8(  888   888   888   888  o.  )88b 
#  888bod8P' `Y888""8o d888b    `Y888""8o o888o o888o o888o 8""888P' 
#  888                                                               
# o888o    

##### Default parameters #####

declare -A params=(
    [interactive]=false
    [reinstall]=false
    [sysctl]=true
    [link]=true
    [essential]=false
    [verbose]=false
    [action]="link"
    [displaym]="lightdm"
    [windowm]="all"
    [helper]="paru"
)

declare -Ar helper_urls=(
    [paru]=""
    [yay]=""
    [pacaur]=""
)

##### Short Argument Parsing #####

# bug: this cannot account for unknown flags
parse_short_toggle_args() {
    interactive $1
    reinstall $1
    sysctl $1
    link $1
    essential $1
    verbose $1

    # if [[ $1 = (^-irslev) ]]; then
    #     echo "Unknown flag"
    #     exit 1
    # fi
}

interactive() {
    if [[ $1 = *i* ]]; then
        params[interactive]=true
    fi
}

reinstall() {
    if [[ $1 = *r* ]]; then
        params[reinstall]=true
    fi
}

sysctl() {
    if [[ $1 = *s* ]]; then
        params[sysctl]=false
    fi
}

link() {
    if [[ $1 = *l* ]]; then
        params[link]=false
    fi
}

essential() {
    if [[ $1 = *e* ]]; then
        params[essential]=true
    fi
}

verbose() {
    if [[ $1 = *v* ]]; then
        params[verbose]=true
    fi
}

##### Valued Argument Parsing #####

parse_valued_args() {
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

parse_args() {
    # when it encounters a valued flag
    state=""
    # index in the argument vector
    local idx=1

    for arg in $@; do
        case $arg in
        -h|--help)
            print_help
            exit
            ;;
        -wm|--window-manager)
            check_missing_value $state
            state="window-manager"
            continue
            ;;
        -dm|--display-manager)
            check_missing_value $state
            state="display-manager"
            continue
            ;;
        -ah|--aur-helper)
            check_missing_value $state
            state="aur-helper"
            continue
            ;;
        -a|--action)
            check_missing_value $state
            state="action"
            continue
            ;;
        --interactive)
            check_missing_value $state
            interactive=true
            ;;
        --reinstall)
            check_missing_value $state
            reinstall=true
            ;;
        --no-sysctl)
            check_missing_value $state
            sysctl=false
            ;;
        --no-link)
            check_missing_value $state
            link=false
            ;;
        --essential)
            check_missing_value $state
            essential=true
            ;;
        --verbose)
            check_missing_value $state
            verbose=true
            ;;
        -*)
            check_missing_value $state
            parse_short_toggle_args $arg
            ;;
        *)
            parse_valued_args $state $arg
            ;;
        esac

        state=""

        idx=$(( idx + 1 ))

    done

    check_missing_value $state
    _check_values
}

_check_values() {

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
    xmonad|i3-gaps|spectrwm|all)
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

confirm() {
    echo "Behaviour:"
    echo "interactive mode:   ${params[interactive]}"
    echo "do reinstallation:  ${params[reinstall]}"
    echo "enable services:    ${params[sysctl]}"
    echo "link dotfiles:      ${params[link]}"
    echo "install essentials: ${params[essential]}"
    echo "verbose mode:       ${params[verbose]}"
    echo "dotfile action:     ${params[action]}"
    echo ""

    echo "Your chosen core apps:"
    echo "Display Manager:   ${params[displaym]}"
    echo "Window Manager(s): ${params[windowm]}"
    echo "AUR helper:        ${params[helper]}"
    echo ""

    if ${params[essential]}; then
        echo "WARNING: essential mode only installs APPLICATIONS.
It does not install base dependencies like the 
X server, pulseaudio, ALSA, graphics drivers, etc.
and assumes that you already have them installed."
        echo ""
    fi
    
    echo -n "Do you want to continue? [Y/n] "
    read choice
    
    case $choice in
    y|yes|Y|Yes)
        echo "Proceeding with bootstrap."
        echo ""
        ;;
    n|no|N|No)
        exit
        ;;
    *)
        fail "Unknown option: $choice" 2
        ;;
    esac
}

#  o8o                           .             oooo  oooo  
#  `"'                         .o8             `888  `888  
# oooo  ooo. .oo.    .oooo.o .o888oo  .oooo.    888   888  
# `888  `888P"Y88b  d88(  "8   888   `P  )88b   888   888  
#  888   888   888  `"Y88b.    888    .oP"888   888   888  
#  888   888   888  o.  )88b   888 . d8(  888   888   888  
# o888o o888o o888o 8""888P'   "888" `Y888""8o o888o o888o 

# The main install function.
install_all() {
    echo '----------| Installation |----------'
    echo '[*] Running full system upgrade:'
    echo ''

    echo 'y' | sudo pacman -Syu
    echo ""

    if ! [[ -e fullpackagelist ]] || ! [[ -e esspackagelist ]]; then
        fail "[!] Cannot find package list required for install - Aborting!" 1
    fi

    echo "[*] Installing packages from package list:"
    echo ""

    if $essential; then
        packagelist=$(cat esspackagelist)
    else
        packagelist=$(cat fullpackagelist)
    fi

    for package in $packagelist; do
        echo "Installing '$package'..."
    done
}

install_helper() {
    case $helper in
    paru)
        ;;
    esac
}

#                 .    o8o  oooo  
#               .o8    `"'  `888  
# oooo  oooo  .o888oo oooo   888  
# `888  `888    888   `888   888  
#  888   888    888    888   888  
#  888   888    888 .  888   888  
#  `V88V"V8P'   "888" o888o o888o 

##### Helper functions #####
fail() {
    echo $1 >&2
    exit $2
}

check_missing_value() {
    [[ -n "$1" ]] && fail "strap.sh: missing value for parameter $1" 2
}

##### The magic happens here. #####
parse_args $@
init
confirm
install_all