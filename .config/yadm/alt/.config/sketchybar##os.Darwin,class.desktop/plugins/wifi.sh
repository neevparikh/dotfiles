#!/usr/bin/env bash


on_click() {
  osascript -e 'tell application "System Events" to tell process "ControlCenter" to click (menu bar item 1 of menu bar 1 whose description contains "Wi‑Fi")'
}

case "$SENDER" in
  "mouse.clicked") on_click
  ;;
  *) exit 0
  ;;
esac
