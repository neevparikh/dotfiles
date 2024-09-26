#!/usr/bin/env bash

mouse_clicked() {
  osascript -e 'tell application "System Events" to tell process "MeetingBar" to click menu bar item 1 of menu bar 2'
}

CHARS=$(python3 -c "print('\ufffc')")

update() {
  RAW=$(osascript -e 'tell application "System Events" to tell process "MeetingBar" to get name of menu bar item 1 of menu bar 2' | sed 's/missing value/No meetings/g' )
  MSG=$(echo "${RAW}" | sed 's/['"$CHARS"']//g' | awk '{$1=$1};1')

  sketchybar -m --set meetingbar icon="" label="${MSG}"
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
    ;;
  *) update
    ;;
esac

