#!/usr/bin/env bash

set_volume() {
  osascript -e "set volume output volume $1"
}

get_volume() {
  echo $(osascript -e 'get output volume of (get volume settings)')
}

mouse_clicked() {
  set_volume $PERCENTAGE
}

update() {
  VOLUME=$(get_volume)
  sketchybar --animate linear 2 --set volume slider.percentage="$VOLUME"
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
    ;;
  "volume_change"|"forced") update
    ;;
  *) exit 0
    ;;
esac
