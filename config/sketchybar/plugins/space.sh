#!/usr/bin/env bash

update() {
  args=()
  is_in=false
  for sid in $(echo $VISIBLE | tr "," " "); do
    if [ "space.$sid" = "$NAME" ]; then
      is_in=true
    fi
  done
  if [ "$is_in" = true ]; then
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
