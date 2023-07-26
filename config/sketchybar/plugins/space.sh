#!/usr/bin/env bash

update() {
  args=()
  if [ "$SELECTED" = "true" ]; then
    args+=(--set $NAME icon.background.y_offset=-9)
 else
    args+=(--set $NAME icon.background.y_offset=-30)
 fi
  
  args+=(--set $NAME icon.highlight=$SELECTED background.drawing=$SELECTED)

  sketchybar -m --animate linear 5 "${args[@]}"
}

mouse_clicked() {
  yabai -m space --focus $SID 2>/dev/null
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  *) update
  ;;
esac
