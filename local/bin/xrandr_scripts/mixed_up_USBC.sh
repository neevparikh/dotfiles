#!/bin/sh
MODE=$(optimus-manager --print-mode)
MODE=$(echo $MODE | cut -d ' ' -f 5- | xargs echo)

if [[ $MODE == "nvidia" ]]; then
    xrandr \
        --output eDP-1-1 --primary --mode 3840x2160 --pos 0x2160 --rotate normal \
        --output DP-1-2 --off \
        --output DP-1-1 --mode 1920x1080 --pos 0x0 --rotate normal --scale 2x2 \
        --output HDMI-1-1 --off
else
    xrandr \
        --output eDP-1 --primary --mode 3840x2160 --pos 0x2160 --rotate normal \
        --output DP-2 --off \
        --output DP-1 --mode 1920x1080 --pos 0x0 --rotate normal --scale 2x2 \
        --output HDMI-1 --off
fi
