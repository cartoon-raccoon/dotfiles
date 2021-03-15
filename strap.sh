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
    echo "(C) 2021 cartoon-raccoon"
    echo ""

    # Check whether OS is Arch
    [[ -e /etc/os-release ]] \
        || fail "[!] Cannot find os-release file, aborting!" 1

    cat /etc/os-release | grep 'Arch Linux' > /dev/null \
        || fail "[!] Unsupported OS, aborting!" 2
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
        action="$2"
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
    echo "Display Manager: $displaym"
    echo "Window Manager : $windowm"
    echo "AUR helper:      $helper"
    echo ""
    
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
        echo "[!] Cannot find package list required for install - Aborting!"
        exit 1
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