#!/usr/bin/env bash

sketchybar --add item battery right                    \
           --set battery update_freq=60               \
                       icon.font="$FONT:Retina:11.5"   \
                       icon.padding_right=3            \
                       icon.color=$YELLOW               \
                       icon.y_offset=2                 \
                       label.y_offset=1                \
                       label.font="$FONT:Bold:12"      \
                       label.color=$YELLOW              \
                       label.padding_right=8           \
                       background.color=$YELLOW         \
                       background.height=2             \
                       background.y_offset=-9          \
                       background.padding_right=8      \
                       script="$PLUGIN_DIR/battery.sh" \
                       icon.padding_left=0 \
                       label.padding_right=1
