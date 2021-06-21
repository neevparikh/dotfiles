#!/bin/zsh
MODE=$(asusctl graphics -g)
MODE=$(echo $MODE | cut -d ' ' -f 4- | xargs echo)

if [[ $MODE == "nvidia" ]]; then
    DP0='DP-0'
    DP1='DP-1'
    DP2='DP-2'
    DP3='DP-3'
    eDP='eDP-1-0'
    HDMI='HDMI-A-1-0'
else
    DP0='DP-0'
    DP1='DP-1'
    DP2='DP-2'
    DP3='DP-3'
    eDP='eDP'
    HDMI='HDMI-A-0'
fi


CMD="xrandr "
CMD+="--output $DP2 --mode 2560x1440 --pos 2560x0 --rotate right "
CMD+="--output $HDMI --primary --mode 2560x1440 --pos 0x534 --rotate normal "
CMD+="--output $eDP --off "
CMD+="--output $DP0 --off "
CMD+="--output $DP1 --off "
CMD+="--output $DP3 --off "
echo $CMD
echo "\n"

eval $CMD
