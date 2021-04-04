#!/bin/bash

# strap.sh: A kinda cool Arch Linux bootstrap script.
# This software is licensed under The Unlicense.
# Copyright (c) 2021 cartoon-raccoon

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
    
    # Check whether git is installed
    pacman -Q git > /dev/null \
        || fail "[!] Git not installed, aborting!"
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

USAGE: ./strap.sh [SUBCOMMAND] [-irsev] [OPTIONS]

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
    
    --no-link/-l:     After installation, do not link dotfiles.
                      (Deprecated, use the install subcommand to prevent linking.)

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
parse_short_toggle_args() {
    interactive $1
    reinstall $1
    sysctl $1
    #link $1
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

# link() {
#     if [[ $1 = *l* ]]; then
#         params[link]=false
#     fi
# }

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
        # --no-link)
        #     check_missing_value $state
        #     link=false
        #     ;;
        --essential)
            check_missing_value $state
            essential=true
            ;;
        --verbose)
            check_missing_value $state
            verbose=true
            ;;
        --*)
            fail "strap.sh: unknown parameter '$arg'" 1
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

confirm() {
    echo "Subcommand: ${params[subcommand]}"
    echo ""
    echo "Behaviour:"
    echo "interactive mode:   ${params[interactive]}"
    echo "do reinstallation:  ${params[reinstall]}"
    echo "enable services:    ${params[sysctl]}"
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
    
    if ! get_user_choice; then
        echo "Exiting!"
        exit 0
    fi

    echo "Proceeding with bootstrap."
    echo ""
}

#*  o8o                           .             oooo  oooo  
#*  `"'                         .o8             `888  `888  
#* oooo  ooo. .oo.    .oooo.o .o888oo  .oooo.    888   888  
#* `888  `888P"Y88b  d88(  "8   888   `P  )88b   888   888  
#*  888   888   888  `"Y88b.    888    .oP"888   888   888  
#*  888   888   888  o.  )88b   888 . d8(  888   888   888  
#* o888o o888o o888o 8""888P'   "888" `Y888""8o o888o o888o 

# The main install function.
install_all() {
    echo '----------| Installation |----------'
    echo '[*] Running full system upgrade:'
    echo ''

    echo 'y' | sudo pacman -Syu || fail "[!] Error on system upgrade, aborting." 1
    echo ""

    echo "[*] Installing AUR helper ${params[helper]}:"
    echo "=========================================="
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
        echo "Helper $helper_bin is already installed."
        echo ""
    fi

    if ! [[ -e fullpackagelist ]] || ! [[ -e esspackagelist ]]; then
        fail "[!] Cannot find package list required for install - Aborting!" 1
    fi

    echo "[*] Installing packages from package list:"
    echo "=========================================="

    if ${params[essential]}; then
        packagelist=$(cat esspackagelist)
    else
        packagelist=$(cat fullpackagelist)
    fi

    install_driver
}

install_helper() {
    local url=${helper_urls[${params[helper]}]}
    local helper=${params[helper]}

    cd ..

    echo "Cloning into $helper..."
    # git clone $url
    echo "cd'ed into $helper-bin..."
    echo "running makepkg..."

    # makepkg -si

    echo $url
    echo ""

    cd $REPO_DIR
}

# drives the entire install process
install_driver() {
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
        install_check $package
    done
}

# check if a package is already installed
# and take action according to whether reinstall is enabled
install_check() {
    if pacman -Q $1 > /dev/null 2>&1; then
        echo -n "$1 is already installed."
        if ${params[reinstall]}; then
            install_pkg $1 true
        else
            echo " Skipping..."
            return 0
        fi
    else
        install_pkg $1 false
    fi
}

# ask the user if they would like to reinstall
install_pkg() {
    # is reinstall
    if $2; then
        if ${params[interactive]}; then
            echo -n " Would you like to reinstall? [Y/n] "
            get_user_choice || return 0
            echo "Reinstalling package $1..."
            _install $1
        else
            echo "Reinstalling package $1..."
            _install $1
        fi
    else
        if ${params[interactive]}; then
            echo -n "Install $1? [Y/n] "
            get_user_choice || return 0
        fi
        echo "Installing package $1..."
        _install $1
    fi
}

# actually handles the install
_install() {
    local pkg=$1
    local helper=${params[helper]}

    # always interactive
    #todo: implement check for why it failed
    if ! sudo pacman -S --noconfirm $pkg; then
        echo ""
        echo "$pkg not found with pacman, using $helper instead."
        $helper -S $pkg
    fi
    return 0
}

#*                 .    o8o  oooo  
#*               .o8    `"'  `888  
#* oooo  oooo  .o888oo oooo   888  
#* `888  `888    888   `888   888  
#*  888   888    888    888   888  
#*  888   888    888 .  888   888  
#*  `V88V"V8P'   "888" o888o o888o 

##### Helper functions #####
fail() {
    echo $1 >&2
    exit $2
}

check_missing_value() {
    [[ -n "$1" ]] && fail "strap.sh: missing value for parameter $1" 2
}

get_user_choice() {
    read choice

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

cleanup() {
    echo ""
    echo "Cleaning up..."

    local orphans=$(pacman -Qqtd)
    if [[ -n $orphans ]]; then
        echo "y" | sudo pacman -Rs $(pacman -Qqtd) \
            || fail "[!] Failed to clean orphaned packages."
    fi

    echo ""
    echo "[*] All done, enjoy your new system!"
}

##### The magic happens here. #####
parse_args $@
init
confirm

if [[ "${params[subcommand]}" != "link" ]]; then
    install_all
else    
    echo "Skipping install."
fi

if [[ "${params[subcommand]}" != "install" ]]; then
    #link_all
    echo "linking..."
else 
    echo "Skipping linking."
fi

cleanup
