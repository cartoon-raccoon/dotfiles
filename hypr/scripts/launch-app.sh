#!/usr/bin/bash

to_launch="$(wofi --show drun --define=drun-print_desktop_file=true | sed -E "s/(\.desktop) /\1:/")"

# if we closed the launcher without selecting anything, prevent the "App launch failed" notif
if [ -z "$to_launch" ]; then
    exit 0
fi
exec uwsm-app -- "$to_launch"