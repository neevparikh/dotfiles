#!/usr/bin/env bash

mouse_clicked() {
  osascript -e 'tell application "System Events" to click menu bar item 1 of menu bar 1 of process "Tailscale"' && update
}

update() {
  STATE=$(tailscale status)
  
  if [ "$STATE" = "Tailscale is stopped." ]; then
    ICON=""
    LABEL="Stopped"
  elif [ "$STATE" = "Logged out." ]; then
    ICON=""
    LABEL="Logged out"
  else
    ICON=""
    LABEL="Connected"
  fi
  
  sketchybar -m --set vpn icon="${ICON}" label="${LABEL}"
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
    ;;
  *) update
    ;;
esac

