#!/usr/bin/env bash

NAME=bluetooth
MAX_LEN=16
SUB_LEN=$(($MAX_LEN - 3))

filter_max_len() {
  if (( ${#1} > $MAX_LEN )); then
    echo "${1:0:$SUB_LEN}..."
  else
    echo $1
  fi
}

on_click() {
  osascript -e 'tell application "System Events" to tell process "ControlCenter" to click (menu bar item 1 of menu bar 1 whose description contains "Bluetooth")'
  update
}

update() {
  STATE=$(system_profiler SPBluetoothDataType | sed -n -e 's/^.*State: //p')
  RAW=$(system_profiler SPBluetoothDataType | sed -En '/^[[:space:]]*Connected:$/,/^.*:$/p' | awk '{gsub(/^.*Connected:/,"")}1' | sed -En 's/^[[:space:]]*//p' | tr -d "\n:")
  DEVICE=$(filter_max_len "$RAW")
  if [ "$STATE" = "Off" ]; then
    sketchybar --set $NAME icon=󰂲 
  elif [[ -z "$DEVICE" ]]; then
    sketchybar --set $NAME icon=󰂯 label="Bluetooth"
  else
    sketchybar --set $NAME icon=󰂯 label="$DEVICE"
  fi
}

case "$SENDER" in
  "mouse.clicked") on_click
  ;;
  *) update
  ;;
esac
