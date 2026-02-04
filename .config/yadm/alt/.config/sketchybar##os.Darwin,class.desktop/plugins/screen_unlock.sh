#!/usr/bin/env bash

LOCK_FILE="/tmp/sketchybar_reload.lock"

# Check if lock file exists and is less than 5 seconds old
if [[ -f "$LOCK_FILE" ]]; then
  lock_age=$(($(date +%s) - $(stat -f %m "$LOCK_FILE")))
  if [[ $lock_age -lt 30 ]]; then
    exit 0
  fi
fi

# Create lock file and reload
touch "$LOCK_FILE"
sleep 0.5
sketchybar --reload
