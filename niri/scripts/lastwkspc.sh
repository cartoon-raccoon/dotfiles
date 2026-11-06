#!/bin/bash

# lastwkspc: A script to act on the last workspace (e.g. move windows/columns, or focus)
# Niri always keeps an empty workspace at the end of the monitor's workspaces. If a window
# gets moved or opened there, a new workspace is created after it. Thus, we can semantically treat moving
# stuff to the last workspace as moving it to a fresh, new workspace.

# by default, if we are going to move something, also focus
focus=true

# default action: focus
action="focus"

if ! [ -z "$1" ]; then
    case "$1" in
    focus)
        # default action is already focus, just shift the args down
        shift
        ;;
    movewin)
        action="movewin"
        shift
        ;;
    movecol)
        action="movecol"
        shift
        ;;
    *)
        echo "unrecognized subcommand"
        exit 1
    esac
fi

if [ $# != 0 ]; then
    case "$1" in
    --focus|-f)
        focus=true
        ;;
    --nofocus|-nf)
        focus=false
        ;;
    *)
        echo "unrecognized argument: $1"
        exit 1
    esac
fi

# make the call to niri just once, save it for subsequent checks
wkspcjson=$(niri msg -j workspaces)
activemon=$(niri msg -j focused-output | jq -r '.name')

# get the index of the workspace we will be operating on *after* parsing arguments
wkspcidx=$(echo "$wkspcjson" | jq "map(select(.output == \"$activemon\")) | length")
actividx=$(echo "$wkspcjson" | jq ".[] | select(.is_active == true) | select(.output == \"$activemon\") | .idx")

case "$action" in
focus)
    if [ "$wkspcidx" == "$actividx" ]; then
        # if current workspace is our target, emulate back-and-forth; focus previous workspace
        niri msg action focus-workspace-previous
    else
        niri msg action focus-workspace "$wkspcidx"
    fi
    ;;
movewin)
    niri msg action move-window-to-workspace "$wkspcidx" --focus="$focus"
    ;;
movecol)
    niri msg action move-column-to-workspace "$wkspcidx" --focus="$focus"
    ;;
*)
    echo "unknown action"
    exit 1
esac

