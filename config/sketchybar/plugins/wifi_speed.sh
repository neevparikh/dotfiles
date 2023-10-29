#!/usr/bin/env bash

update() {
  CURRENT_WIFI="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport --getinfo)"
  TX_RATE="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport --getinfo | grep -o 'lastTxRate: .*' | sed 's/^lastTxRate: //')"
  SPEED="$(echo "scale=2; $TX_RATE/1024.0" | bc)"
  SPEED_CLIPPED=$(awk '{ print ($0 > 1) ? 1.0 : $0 }' <<<"$SPEED")
  sketchybar --push wifi_speed $SPEED
}

case "$SENDER" in
  *) update
  ;;
esac
