#!/bin/sh

update() {
  echo "$(gdate '+%a %b %-d %I:%M%P')"
  sketchybar --set calendar label="$(gdate '+%a %b %-d %I:%M%P')"
}

case "$SENDER" in
  *) update
  ;;
esac
