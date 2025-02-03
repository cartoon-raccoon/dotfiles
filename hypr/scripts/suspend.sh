#!/bin/bash

if [[ "$(< /sys/class/power_supply/BAT1/status)" == "Discharging" ]]; then
    echo "Suspending..."
    systemctl suspend
else
    exit 0
fi