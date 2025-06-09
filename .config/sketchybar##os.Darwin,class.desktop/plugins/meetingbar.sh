#!/usr/bin/env bash

MAX_LEN=40
SUB_LEN=$(($MAX_LEN - 3))

filter_max_len() {
  if (( ${#1} > $MAX_LEN )); then
    echo "${1:0:$SUB_LEN}..."
  else
    echo $1
  fi
}

mouse_clicked() {
  osascript -e 'tell application "System Events" to tell process "MeetingBar" to click menu bar item 1 of menu bar 2'
}

update() {
  RAW=$(osascript -e 'tell application "System Events" to tell process "MeetingBar" to get name of menu bar item 1 of menu bar 2' | sed 's/missing value/No meetings/g')
  MSG=$(filter_max_len "$RAW")

  sketchybar -m --set meetingbar icon="" label="${MSG}"
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
    ;;
  *) update
    ;;
esac

