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
        interactive=true
    fi
}

reinstall() {
    if [[ $1 = *r* ]]; then
        reinstall=true
    fi
}

sysctl() {
    if [[ $1 = *s* ]]; then
        sysctl=false
    fi
}

link() {
    if [[ $1 = *l* ]]; then
        link=false
    fi
}

essential() {
    if [[ $1 = *e* ]]; then
        essential=true
    fi
}

verbose() {
    if [[ $1 = *v* ]]; then
        verbose=true
    fi
}

##### Valued Argument Parsing #####

parse_valued_args() {
    case $1 in
    winman)
        windowm="$2"
        ;;
    disman)
        displaym="$2"
        ;;
    aurhelp)
        helper="$2"
        ;;
    action)
        case $2 in
        ln|link)
            action="link"
            ;;
        cp|copy)
            action="copy"
            ;;
        mv|move)
            action="move"
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
    idx=1

    for arg in $@; do
        case $arg in
        -h|--help)
            print_help
            exit
            ;;
        -wm|--window-manager)
            state="winman"
            continue
            ;;
        -dm|--display-manager)
            state="disman"
            continue
            ;;
        -ah|--aur-helper)
            state="aurhelp"
            continue
            ;;
        -a|--action)
            state="action"
            continue
            ;;
        --interactive)
            interactive=true
            ;;
        --reinstall)
            reinstall=true
            ;;
        --no-sysctl)
            sysctl=false
            ;;
        --no-link)
            link=false
            ;;
        --essential)
            essential=true
            ;;
        --verbose)
            verbose=true
            ;;
        -*)
            parse_short_toggle_args $arg
            ;;
        *)
            parse_valued_args $state $arg
            ;;
        esac

        state=""

        idx=$(( idx + 1 ))

    done

    check_values
}

check_values() {

    # checking helper
    case $helper in
    paru|yay|pacaur)
        ;;
    *)
        fail "strap.sh: unrecognized AUR helper: $helper" 2
        ;;
    esac

    # checking display manager
    case $displaym in
    lightdm|sddm)
        ;;
    *)
        fail "strap.sh: unsupported display manager: $displaym" 2
        ;;
    esac

    # checking window manager
    case $windowm in
    xmonad|i3-gaps|spectrwm|all)
        ;;
    *)
        fail "strap.sh: unsupported window manager: $windowm" 2
        ;;
    esac

    case $action in
    link|copy|move|ln|cp|mv)
        ;;
    *)
        fail "strap.sh: unrecognized dotfile action: $action" 2
        ;;
    esac
}

confirm() {
    echo "Behaviour:"
    echo "interactive mode:   $interactive"
    echo "do reinstallation:  $reinstall"
    echo "enable services:    $sysctl"
    echo "link dotfiles:      $link"
    echo "install essentials: $essential"
    echo "verbose mode:       $verbose"
    echo "dotfile action:     $action"
    echo ""

    echo "Your chosen core apps:"
    echo "Display Manager:   $displaym"
    echo "Window Manager(s): $windowm"
    echo "AUR helper:        $helper"
    echo ""

    if $essential; then
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

##### Helper functions #####
fail() {
    echo $1 >&2
    exit $2
}

# setting defaults

##### Core Applications #####

helper="paru"
displaym="lightdm"
windowm="all"

##### Behaviour Flags #####

# toggle flags
interactive=false
reinstall=false
sysctl=true
link=true
essential=false
verbose=false

# valued flags
action="link"

##### The magic happens here. #####
parse_args $@
init
confirm
install_all