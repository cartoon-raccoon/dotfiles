#!/bin/bash

#############################
##### Core Applications #####
#############################
helper="paru"
displaym="lightdm"
windowm="all"

###########################
##### Behaviour Flags #####
###########################

# setting some default values

# toggle flags
interactive=false
reinstall=false
sysctl=true
link=true
essential=false
verbose=false

# valued flags
action="link"


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
        essential=false
    fi
}

verbose() {
    if [[ $1 = *v* ]]; then
        verbose=false
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
        echo "Unknown parameter: $1"
        exit 1
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

parse_args $@

echo "interactive: $interactive"
echo "reinstall: $reinstall"
echo "sysctl: $sysctl"
echo "link: $link"
echo "essential: $essential"
echo "verbose: $verbose"
echo "action: $action"
echo ""
echo "display: $displaym"
echo "window: $windowm"
echo "helper: $helper"