#!/bin/bash

# A script to send a termination signal to the process controlling a window,
# selected using niri msg pick-window.

# This is usually used to kill unresponsive windows.

case $1 in
-i)
    signal="SIGINT"
    ;;
-t)
    signal="SIGTERM"
    ;;
-k)
    signal="SIGKILL"
    ;;
esac

if [ -z "$signal" ]; then
    echo "no signal given, exiting"
    exit 1
fi

pid=$(niri msg --json pick-window | jq -r '.pid // empty')

if [ -z "$pid" ]; then
    echo "could not get pid, exiting"
    exit 0
fi

echo "sending $signal to process $pid"

if kill "-$signal" "$pid"; then
    echo "sending signal failed"; exit 1
fi

exit 0