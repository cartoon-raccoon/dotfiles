#!/bin/sh
state="${XDG_STATE_HOME:-$HOME/.local/state}/hyprpm-built-version"
current="$(hyprctl version -j | jq -r '.commit')"

if [ "$(cat "$state" 2>/dev/null)" != "$current" ]; then
    hyprctl notify 1 3000 0 "Hyprland was updated, updating plugins"
    hyprpm update && echo "$current" > "$state"
fi

hyprpm reload -n
