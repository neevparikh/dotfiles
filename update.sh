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

# zsh
cp /home/neev/.zshrc $PWD/zsh/zshrc
cp /home/neev/.oh-my-zsh/custom/themes/gruvbox.zsh-theme $PWD/zsh/gruvbox.zsh-theme

# libinput 
cp /usr/share/X11/xorg.conf.d/40-libinput.conf $PWD/libinput/libinput.conf

# feh
cp /home/neev/.fehbg $PWD/feh/fehbg

# vim
cp /home/neev/.vimrc $PWD/vim/vimrc
