#!/usr/bin/env bash

update_display() {
  NUM_MONITORS=$(aerospace list-monitors --format %{monitor-id} | wc -l | xargs)
  sid=${NAME:6:2}
  if [[ $sid -gt 20 && $NUM_MONITORS -gt 2 ]]; then
    display=3
  elif [[ $sid -le 20 && $sid -gt 10 && $NUM_MONITORS -gt 1 ]]; then
    display=2
  else
    display=1
  fi
  sketchybar -m --set $NAME display=$display

  if [[ $NAME == "space.20" ]]; then
    if [[ $NUM_MONITORS -gt 2 ]]; then
      sketchybar --reorder space.1 space.2 space.3 space.4 space.5 space.6 space.7 space.8 space.9 space.10 \
        space.11 space.12 space.13 space.14 space.15 space.16 space.17 space.18 space.19 space.20
    else
      sketchybar --reorder space.21 space.22 space.23 space.24 space.25 space.26 space.27 space.28 space.29 space.30

    fi
  fi
}

update() {
  args=()

  echo $VISIBLE
  is_in=false
  for sid in $(echo $VISIBLE | tr "," " "); do
    if [ "space.$sid" == "$NAME" ]; then
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
  "display_change") update_display
  ;;
  *) update
  ;;
esac
