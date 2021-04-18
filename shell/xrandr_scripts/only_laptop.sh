#!/bin/sh
MODE=$(optimus-manager --print-mode)
MODE=$(echo $MODE | cut -d ' ' -f 5- | xargs echo)

if [[ $MODE == "nvidia" ]]; then
    xrandr \
        --output DP-1-1 --off \
        --output DP-1-2 --off \
        --output eDP-1-1 --primary --mode 3840x2160 --rotate normal \
        --output HDMI-1-1 --off
else
    xrandr \
        --output DP-1 --off \
        --output DP-2 --off \
        --output eDP-1 --primary --mode 3840x2160 --rotate normal \
        --output HDMI-1 --off
fi
