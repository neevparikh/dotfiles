#!/usr/bin/env bash
NAME=bluetooth

sketchybar --add item $NAME right                        \
           --set $NAME update_freq=60                    \
                       icon.font="$FONT:Retina:14"      \
                       icon.padding_right=0             \
                       icon.padding_left=2              \
                       icon.color=$PEACH                  \
                       icon.y_offset=2                  \
                       label.y_offset=1                 \
                       label.font="$FONT:Bold:12"       \
                       label.color=$PEACH                 \
                       label.padding_right=0            \
                       background.color=$PEACH            \
                       background.height=2              \
                       background.y_offset=-9           \
                       background.padding_right=8       \
                       script="$PLUGIN_DIR/$NAME.sh"     \
            --subscribe $NAME mouse.clicked
