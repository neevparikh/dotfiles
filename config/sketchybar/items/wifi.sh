#!/usr/bin/env bash

sketchybar --add item wifi right                        \
           --set wifi update_freq=20                    \
                       icon.font="$FONT:Retina:19"      \
                       icon.padding_right=2             \
                       icon.color=$RED                  \
                       icon.y_offset=1                  \
                       label.y_offset=1                 \
                       label.font="$FONT:Bold:12"       \
                       label.color=$RED                 \
                       label.padding_right=8            \
                       background.color=$RED            \
                       background.height=2              \
                       background.y_offset=-9           \
                       background.padding_right=8       \
                       script="$PLUGIN_DIR/wifi.sh"     \
                       icon.padding_left=0              \
                       label.padding_right=1            \
            --subscribe wifi mouse.clicked
