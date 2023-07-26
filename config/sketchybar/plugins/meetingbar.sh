#!/usr/bin/env bash

MSG=$(osascript -e 'tell application "System Events" to tell process "MeetingBar" to get name of menu bar item 1 of menu bar 2')
sketchybar -m --set meetingbar             \
  icon=""                                 \
  label="$MSG"
