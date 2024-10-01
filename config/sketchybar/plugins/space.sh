#!/usr/bin/env bash

update() {
  args=()

  if [ "space.$FOCUSED" = "$NAME" ]; then
    args+=(--set $NAME icon.highlight=on background.drawing=on)
  else
    args+=(--set $NAME icon.highlight=off background.drawing=off)
  fi
  
  sketchybar -m "${args[@]}"
}

mouse_clicked() {
  aerospace workspace $SID 2>/dev/null
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  *) update
  ;;
esac
