#!/usr/bin/bash
# launch an app through uswm, using wofi as the app chooser.
to_launch="$(wofi --show drun --define=drun-print_desktop_file=true | sed -E "s/(\.desktop) /\1:/")"

# if we closed the launcher without choosing anything, prevent the "App launch failed" notification
if [ -z $to_launch ]; then
    exit 0
fi
exec uwsm-app -- "$to_launch"