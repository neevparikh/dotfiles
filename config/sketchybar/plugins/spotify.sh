#!/bin/bash
#
# built on https://github.com/FelixKratz/dotfiles/blob/master/.config/sketchybar/plugins/spotify.sh

next() {
  osascript -e 'tell application "Spotify" to play next track'
}

back() {
  osascript -e 'tell application "Spotify" to play previous track'
}

play() {
  osascript -e 'tell application "Spotify" to playpause'
}

repeat() {
  REPEAT=$(osascript -e 'tell application "Spotify" to get repeating')
  if [ "$REPEAT" = "false" ]; then
    sketchybar -m --set spotify.repeat icon.highlight=on
    osascript -e 'tell application "Spotify" to set repeating to true'
  else 
    sketchybar -m --set spotify.repeat icon.highlight=off
    osascript -e 'tell application "Spotify" to set repeating to false'
  fi
}

shuffle() {
  SHUFFLE=$(osascript -e 'tell application "Spotify" to get shuffling')
  if [ "$SHUFFLE" = "false" ]; then
    sketchybar -m --set spotify.shuffle icon.highlight=on
    osascript -e 'tell application "Spotify" to set shuffling to true'
  else 
    sketchybar -m --set spotify.shuffle icon.highlight=off
    osascript -e 'tell application "Spotify" to set shuffling to false'
  fi
}

MAX_LEN=24
SUB_LEN=$(($MAX_LEN - 3))

filter_max_len() {
  if (( ${#1} > $MAX_LEN )); then
    echo "${1:0:$SUB_LEN}..."
  else
    echo $1
  fi
}

update() {
  TRACK=$(filter_max_len "$(osascript -e 'tell application "Spotify" to get name of current track')")
  ARTIST=$(filter_max_len "$(osascript -e 'tell application "Spotify" to get artist of current track')")
  ALBUM=$(filter_max_len "$(osascript -e 'tell application "Spotify" to get album of current track')")
  SHUFFLE=$(osascript -e 'tell application "Spotify" to get shuffling')
  REPEAT=$(osascript -e 'tell application "Spotify" to get repeating')
  COVER=$(osascript -e 'tell application "Spotify" to get artwork url of current track')

  args=()
  curl -s --max-time 20 "$COVER" -o /tmp/cover.jpg
  if [ "$ARTIST" == "" ]; then
    args+=(--set spotify.title label="$TRACK"
           --set spotify.anchor label=$([-z "$TRACK"] && "Spotify" || "$TRACK")
           --set spotify.album label="Podcast"
           --set spotify.artist label="$ALBUM"  )
  else
    args+=(--set spotify.title label="$TRACK"
           --set spotify.anchor label="$TRACK"
           --set spotify.album label="$ALBUM"
           --set spotify.artist label="$ARTIST")
  fi

  if [ "$(osascript -e 'tell application "Spotify" to get player state')" = "playing" ]; then
    args+=(--set spotify.play icon=󰏦)
  else
    args+=(--set spotify.play icon=󰐍)
  fi

  args+=(--set spotify.shuffle icon.highlight=$SHUFFLE
         --set spotify.repeat icon.highlight=$REPEAT
         --set spotify.cover background.image="/tmp/cover.jpg" background.color=0x00000000
         --set spotify.anchor drawing=on)
  sketchybar -m "${args[@]}"
}

scrubbing() {
  DURATION_MS=$(osascript -e 'tell application "Spotify" to get duration of current track')
  DURATION=$((DURATION_MS/1000))

  TARGET=$((DURATION*PERCENTAGE/100))
  osascript -e "tell application \"Spotify\" to set player position to $TARGET"
  sketchybar --set spotify.state slider.percentage=$PERCENTAGE
}

scroll_no_animate() {
  DURATION_MS=$(osascript -e 'tell application "Spotify" to get duration of current track')
  DURATION=$((DURATION_MS/1000))

  FLOAT="$(osascript -e 'tell application "Spotify" to get player position')"
  TIME=${FLOAT%.*}
  
  sketchybar --set spotify.state slider.percentage="$((TIME*100/DURATION))" \
                                 icon="$(date -ju -f "%s" $TIME '+%M:%S')" \
                                 label="$(date -ju -f "%s" $DURATION '+%M:%S')"
}

scroll() {
  DURATION_MS=$(osascript -e 'tell application "Spotify" to get duration of current track')
  DURATION=$((DURATION_MS/1000))

  FLOAT="$(osascript -e 'tell application "Spotify" to get player position')"
  TIME=${FLOAT%.*}
  
  sketchybar --animate linear 10 \
             --set spotify.state slider.percentage="$((TIME*100/DURATION))" \
                                 icon="$(date -ju -f "%s" $TIME '+%M:%S')" \
                                 label="$(date -ju -f "%s" $DURATION '+%M:%S')"
}

mouse_clicked() {
  scroll_no_animate
  case "$NAME" in
    "spotify.anchor") update
    ;;
    "spotify.next") next
    ;;
    "spotify.back") back
    ;;
    "spotify.play") play
    ;;
    "spotify.shuffle") shuffle
    ;;
    "spotify.repeat") repeat
    ;;
    "spotify.state") scrubbing
    ;;
    *) exit
    ;;
  esac
}

popup() {
  sketchybar --set spotify.anchor popup.drawing=$1
}

routine() {
  case "$NAME" in
    "spotify.state") scroll
    ;;
    *) update
    ;;
  esac
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  "mouse.exited"|"mouse.exited.global") popup off
  ;;
  "routine") routine
  ;;
  "forced") update
  ;;
  *) update
  ;;
esac
