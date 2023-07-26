#!/usr/bin/env bash

sketchybar --add item meetingbar right                    \
           --set meetingbar update_freq=60               \
                       icon.font="$FONT:Retina:16.0"   \
                       icon.padding_right=3            \
                       icon.color=$RED               \
                       icon.y_offset=2                 \
                       label.y_offset=1                \
                       label.font="$FONT:Bold:12"      \
                       label.color=$RED              \
                       label.padding_right=8           \
                       background.color=$RED         \
                       background.height=2             \
                       background.y_offset=-9          \
                       background.padding_right=8      \
                       script="$PLUGIN_DIR/meetingbar.sh" \
                       icon.padding_left=0 \
                       label.padding_right=1
