#!/bin/sh
MODE=$(asusctl graphics -g)
MODE=$(echo $MODE | cut -d ' ' -f 4- | xargs echo)

if [[ $MODE == "nvidia" ]]; then
    DP1='DP-1'
    DP2='DP-2'
    DP3='DP-3'
    eDP='eDP-1-0'
    HDMI='HDMI-A-1-0'
else
    DP1='DP-1'
    DP2='DP-2'
    DP3='DP-3'
    eDP='eDP'
    HDMI='HDMI-A-1-0'
fi


CMD="xrandr "
CMD+="--output $eDP --primary --auto "
CMD+="--output $HDMI --off "
CMD+="--output $DP1 --off "
CMD+="--output $DP2 --off "
CMD+="--output $DP3 --off "
echo $CMD
echo "\n"

eval $CMD
