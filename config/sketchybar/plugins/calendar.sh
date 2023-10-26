#!/bin/sh

update() {
  sketchybar --set calendar label="$(gdate '+%a %b %-d %I:%M%P')"
}

case "$SENDER" in
  *) update
  ;;
esac
