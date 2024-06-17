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
  CURRENT_WIFI="$($HOME/.local/bin/spaceport)"

  RAW="$(echo "$CURRENT_WIFI" | grep -o "^SSID: .*" | sed "s/^SSID: //")"
  SSID=$(filter_max_len "$RAW")
  STATE=$(echo "$CURRENT_WIFI" | grep -o "^Power: .*" | sed "s/^Power: //")
  TX_RATE="$(echo "$CURRENT_WIFI" | grep -o "^Tx Rate: .*" | sed "s/^Tx Rate: // ; s/\.[0-9] Mbps//")"
  SIGNAL=$(echo "$CURRENT_WIFI" | grep -o "^RSSI: .*" | sed "s/^RSSI: // ; s/ dBm//")
  NOISE=$(echo "$CURRENT_WIFI" | grep -o "^Noise: .*" | sed "s/^Noise: // ; s/ dBm//")

  SPEED="$(echo "scale=2; $TX_RATE/1024.0" | bc)"
  SPEED_CLIPPED=$(awk '{ print ($0 > 1) ? 1.0 : $0 }' <<<"$SPEED")

  SNR=$(echo "scale=2; $SIGNAL - $NOISE" | bc)
  SNR_CLIPPED=$(awk '{ print ($0 > 100) ? 100 : $0 }' <<<"$SNR")

  if [ "$STATE" = "Off [Off]" ]; then
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

  if [ "$SSID" = "None" ]; then
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
