#!/bin/bash

# default values
helper="paru"
displaym="lightdm"
windowm="all"

# default behaviour flags
interactive="no"
reinstall="no"
sysctl="yes"
link="yes"
essential="no"
verbose="no"
action="link"


parse_args() {
    for arg in $@; do
        case $arg in
        -*i*)
                interactive="yes"
            ;;
        -*r*)
                reinstall="yes"
            ;;
        esac
    done
}

parse_args $@

echo "interactive: $interactive"
echo "reinstall: $reinstall"