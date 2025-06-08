#!/usr/bin/env bash

mouse_clicked() {
  pkill "Mighty Mitts" && open -a "Mighty Mitts" && sleep 1
  osascript -e 'tell application "System Events" to tell process "Mighty Mitts" to click menu bar item 1 of menu bar 1'
  sleep 2
  update
}

update() {
  MSG=$(osascript -e 'tell application "System Events" to tell process "Mighty Mitts" to get name of menu bar item 1 of menu bar 1' | sed 's/No keyboard selected./✕/g' | sed 's/missing value/✕/g' | sed -E 's/[[:space:]]+/ /g')

  sketchybar -m --set bluetooth_battery icon="" label="${MSG}"
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
    ;;
  *) update
    ;;
esac

