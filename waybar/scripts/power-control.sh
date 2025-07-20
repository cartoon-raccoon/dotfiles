#!/bin/bash

function run_shutdown() {
    if zenity --question\
        --text="Do you want to shut down?"\
        --icon=system-shutdown\
        --title=Shutdown; then
        shutdown now
    else
        exit 0
    fi
}

function run_restart() {
    if zenity --question\
        --text="Do you want to restart?"\
        --icon=view-refresh\
        --title=Restart; then
        reboot
    else
        exit 0
    fi
}

function run_lock() {
    hyprlock
}

function run_exit() {
    if zenity --question\
        --text="Do you want to log out?"\
        --icon=application-exit\
        --title=Logout; then
        hyprctl dispatch exec uwsm stop
    else
        exit 0
    fi
}

case $1 in
-s)
    run_shutdown
    ;;
-r)
    run_restart
    ;;
-l)
    run_lock
    ;;
-e)
    run_exit
    ;;
esac


