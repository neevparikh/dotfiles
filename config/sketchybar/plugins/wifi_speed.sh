#!/usr/bin/env bash

MAX_LEN=16
SUB_LEN=$(($MAX_LEN - 3))

filter_max_len() {
  if (( ${#1} > $MAX_LEN )); then
    echo "${1:0:$SUB_LEN}..."
  else
    echo $1
  fi
}

update() {
  CURRENT_WIFI="$(cat /tmp/spaceport.json)"

  RAW="$(echo "$CURRENT_WIFI" | jq -r .ssid)"
  STATE=$(echo "$CURRENT_WIFI" | jq -r .power)
  TX_RATE="$(echo "$CURRENT_WIFI" | jq -r .'tx_rate | round')"
  SIGNAL=$(echo "$CURRENT_WIFI" | jq -r .rssi)
  NOISE=$(echo "$CURRENT_WIFI" | jq -r .noise)

  SSID=$(filter_max_len "$RAW")

  SPEED="$(echo "scale=2; $TX_RATE/1024.0" | bc)"
  SPEED_CLIPPED=$(awk '{ print ($0 > 1) ? 1.0 : $0 }' <<<"$SPEED")

  SNR=$(echo "scale=2; $SIGNAL - $NOISE" | bc)
  SNR_CLIPPED=$(awk '{ print ($0 > 100) ? 100 : $0 }' <<<"$SNR")

  if [ "$STATE" = "false" ]; then
    ICON="󰤭"
  else
    case ${SNR_CLIPPED} in
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
  fi

  if [ "$SSID" = "null" ]; then
    SSID="Disconnected"
    ICON="󰤫"
  fi

  sketchybar --push wifi_speed $SPEED_CLIPPED \
             --set wifi_speed_mbps label="${SNR_CLIPPED}db ${TX_RATE}mb/s" \
             --set wifi label="$SSID" icon="$ICON"
}

case "$SENDER" in
  *) update
  ;;
esac
