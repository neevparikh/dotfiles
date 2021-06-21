#!/bin/zsh
MODE=$(asusctl graphics -g)
MODE=$(echo $MODE | cut -d ' ' -f 4- | xargs echo)

SCALE1=1.33
SCALE2=1
WRES=1920
HRES=1080
POS=$(( WRES * SCALE1 + 1))
POS=${POS%.*}

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
CMD+="--output $DP2 --primary --mode ${WRES}x${HRES} --scale ${SCALE1}x${SCALE1} --pos 0x0 --rotate normal "
CMD+="--output $HDMI --mode ${WRES}x${HRES} --scale ${SCALE2}x${SCALE2} --pos ${POS}x0 --rotate normal "
CMD+="--output $eDP --off "
CMD+="--output $DP1 --off "
CMD+="--output $DP3 --off "
echo $CMD
echo "\n"

eval $CMD
