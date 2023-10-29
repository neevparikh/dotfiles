#!/usr/bin/env bash

MAX_LEN=16
SUB_LEN=$(($MAX_LEN - 3))

on_click() {
  osascript -e 'tell application "System Events" to tell process "ControlCenter" to click (menu bar item 1 of menu bar 1 whose description contains "Wi‑Fi")'
  update
}

filter_max_len() {
  if (( ${#1} > $MAX_LEN )); then
    echo "${1:0:$SUB_LEN}..."
  else
    echo $1
  fi
}

update() {
  CURRENT_WIFI="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport --getinfo)"
  RAW="$(echo "$CURRENT_WIFI" | grep -o "SSID: .*" | sed 's/^SSID: //')"
  SSID=$(filter_max_len "$RAW")

  SIGNAL=$(echo "$CURRENT_WIFI" | grep -o "agrCtlRSSI: .*" | sed "s/^agrCtlRSSI: //")
  NOISE=$(echo "$CURRENT_WIFI" | grep -o "agrCtlNoise: .*" | sed "s/^agrCtlNoise: //")
  SNR=$(echo "scale=2; ($NOISE - $SIGNAL) * -1" | bc)

  STATE=$(echo "$CURRENT_WIFI" | grep -o "AirPort: .*" | sed "s/^AirPort: //")
  
  if [ "$STATE" = "Off" ]; then
    sketchybar --set wifi label="Off" icon=󰤭
  else
    case ${SNR} in
       100) ICON="󰤨" ;;
        9[0-9]) ICON="󰤨" ;; 
        8[0-9]) ICON="󰤨" ;; 
        7[0-9]) ICON="󰤨" ;; 
        6[0-9]) ICON="󰤨" ;; 
        5[0-9]) ICON="󰤨" ;; 
        4[0-9]) ICON="󰤨" ;; 
        3[0-9]) ICON="󰤢" ;;
        2[0-9]) ICON="󰤢" ;;
        1[0-9]) ICON="󰤟" ;;
        *) ICON="󰤯"
    esac

    if [ "$SSID" = "" ]; then
      sketchybar --set wifi label="Disconnected" icon=󰤫
    else
      sketchybar --set wifi label="$SSID" icon=$ICON
    fi
  fi
}

case "$SENDER" in
  "mouse.clicked") on_click
  ;;
  *) update
  ;;
esac
