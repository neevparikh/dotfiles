#!/bin/bash

CFG='/home/neev/.config'

# make dir if not exists
mkdir -p i3 i3status termite rofi wallpaper
mkdir -p rofi/themes/
# i3
cp $CFG/i3/config $PWD/i3/i3-config
cp $CFG/i3status/config $PWD/i3status/i3status-config

# rofi
cp $CFG/rofi/config $PWD/rofi/rofi-config
cp /usr/share/rofi/themes/*.rasi $PWD/rofi/themes/

# termite
cp $CFG/termite/config $PWD/termite/termite-config

# wallpapers
cp /usr/share/backgrounds/*.png $PWD/wallpaper/

