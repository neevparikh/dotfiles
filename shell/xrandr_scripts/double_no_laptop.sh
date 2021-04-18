#!/bin/zsh
MODE=$(optimus-manager --print-mode)
MODE=$(echo $MODE | cut -d ' ' -f 5- | xargs echo)

SCALE1=2
SCALE2=1.75
WRES=1920
HRES=1080
POS=$(( WRES * SCALE1 ))
POS=${POS%.*}

if [[ $MODE == "nvidia" ]]; then
    DP1='DP-1-1'
    DP2='DP-1-2'
    eDP='eDP-1-1'
    HDMI='HDMI-1-1'
else
    DP1='DP-1'
    DP2='DP-2'
    eDP='eDP-1'
    HDMI='HDMI-1'
fi


xrandr \
    --output $DP1 --primary --mode $WRES\x$HRES --scale $SCALE1\x$SCALE1 --pos 0x0 --rotate normal \
    --output $DP2 --mode $WRES\x$HRES --scale $SCALE2\x$SCALE2 --pos $POS\x0 --rotate normal \
    --output $eDP --off \
    --output $HDMI --off
