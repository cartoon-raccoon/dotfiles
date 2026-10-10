#!/bin/bash

# Name a workspace, using niri msg action set-workspace.

activwkspcjson=$(niri msg -j workspaces | jq '.[] | select(.is_active == true)')
activeidx=$(echo "$activwkspcjson" | jq '.idx')
activename=$(echo "$activwkspcjson" | jq -r '.name')

if [[ "$activename" =~ "Main"|"Dev"|"Social"|"Music" ]] || [[ "$activeidx" -le 4 ]]; then
    echo "currently on static workspace, ignoring"
    notify-send -t 5000 --app-name="Niri" "Name Workspace" "Cannot edit static workspace \`$activename\`"
    exit 0
fi

if [ "$1" == "set" ]; then
    if [ -z "$2" ]; then
        name=$(zenity --entry --text="Enter workspace name:" --title="Set Workspace Name")
    else
        name="$2"
    fi

    [ -z "$name" ] && exit 0;

    case $name in
    "Main"|"Dev"|"Social"|"Music")
        echo "cannot name workspace to a reserved name, ignoring"
        exit 0
        ;;
    *)
        echo "naming focused workspace to \"$name\""
        if niri msg action set-workspace-name "$name"; then
            notify-send -t 5000 --app-name="Niri" "Name Workspace" "Workspace has been named to \"$name\""
        else
            echo "unable to name workspace, exiting"
            exit 1
        fi
        ;;
    esac
elif [ "$1" == "unset" ]; then
    niri msg action unset-workspace-name
else
    echo "unknown command"
    exit 1
fi