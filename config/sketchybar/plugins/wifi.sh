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
  CURRENT_WIFI="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I)"

  RAW="$(echo "$CURRENT_WIFI" | grep -o "SSID: .*" | sed 's/^SSID: //')"
  SSID=$(filter_max_len "$RAW")

  CURR_TX_bits="$(echo "$CURRENT_WIFI" | grep -o "lastTxRate: .*" | sed 's/^lastTxRate: //')"
  CURR_TX=$(echo "scale=1; $CURR_TX_bits / 8" | bc)

  if [ "$SSID" = "" ]; then
    sketchybar --set wifi label="Disconnected" icon=󰖪
  else
    sketchybar --set wifi label="$SSID (${CURR_TX} MB/s)" icon=󰖩
  fi
}

case "$SENDER" in
  "mouse.clicked") on_click
  ;;
  *) update
  ;;
esac
