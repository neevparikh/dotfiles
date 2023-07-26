#!/usr/bin/env bash

volume=(
  icon="󰖀"
  icon.drawing=on
  icon.y_offset=1
  icon.font="$FONT:Retina:17.0"
  label.drawing=off
  slider.background.corner_radius=1
  slider.background.height=1
  slider.background.y_offset=0
  slider.background.color=$BG
  slider.highlight_color=$FGALT
  slider.knob="󱋱"
  slider.knob.color=$FGALT
  slider.knob.y_offset=1
  slider.knob.font="$FONT:Retina:11.0"
  slider.width=70
  slider.percentage=40
  background.color=$FG
  background.height=2
  background.y_offset=-9
  background.padding_right=8
  script="$PLUGIN_DIR/volume.sh"
)

sketchybar --add slider volume right \
           --set volume "${volume[@]}" \
           --subscribe volume volume_changed mouse.clicked
