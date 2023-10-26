#!/bin/sh

update() {
  sketchybar --set $NAME label="$(gdate '+%a %b %-d | %I:%M%P')"
}

case "$SENDER" in
  *) update
  ;;
esac
