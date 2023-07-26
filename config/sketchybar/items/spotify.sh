#!/bin/bash
#
# built on https://github.com/FelixKratz/dotfiles/blob/master/.config/sketchybar/items/spotify.sh

SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged"
POPUP_SCRIPT="sketchybar -m --set spotify.anchor popup.drawing=toggle"

spotify_anchor=(
  script="$PLUGIN_DIR/spotify.sh"
  click_script="$POPUP_SCRIPT"
  popup.horizontal=on
  popup.align=center
  popup.height=150
  icon=󰓇
  icon.color="$GREEN"
  icon.y_offset=1
  icon.padding_right=3
  icon.font="$FONT:Retina:18.0"
  label="$TRACK"
  label.drawing=on
  label.color="$GREEN"
  label.font="$FONT:Bold:12.0"
  background.color=$GREEN
  background.height=2
  background.y_offset=-9
  background.padding_right=8
  drawing=on
)

spotify_cover=(
  script="$PLUGIN_DIR/spotify.sh"
  click_script="$POPUP_SCRIPT"
  label.drawing=off
  icon.drawing=off
  padding_left=12
  padding_right=10
  background.image.scale=0.2
  background.image.drawing=on
  background.drawing=on
)

spotify_title=(
  icon.drawing=off
  padding_left=0
  padding_right=0
  label.font="$FONT:Bold:13.0"
  y_offset=55
  width=0
)

spotify_artist=(
  icon.drawing=off
  y_offset=30
  padding_left=0
  padding_right=0
  width=0
)

spotify_album=(
  icon.drawing=off
  padding_left=0
  padding_right=0
  y_offset=15
  width=0
)

spotify_state=(
  width=0
  icon.drawing=on
  icon.font="$FONT:Retina:10.0"
  icon.width=35
  icon.padding_right=3
  icon="00:00"
  label.drawing=on
  label.font="$FONT:Retina:10.0"
  label.width=35
  label.padding_left=3
  label="00:00"
  padding_left=0
  padding_right=0
  y_offset=-15
  slider.background.height=6
  slider.background.corner_radius=1
  slider.background.color=$GREY
  slider.highlight_color=$GREEN
  slider.percentage=40
  slider.width=120
  script="$PLUGIN_DIR/spotify.sh"
  update_freq=1
  updates=when_shown
)

CONTROL_FONT="$FONT:Bold:26.0"
REPEAT_CONTROL_FONT="$FONT:Bold:32.0"

spotify_shuffle=(
  icon=󰒝 # 󰒟
  icon.font="$CONTROL_FONT"
  icon.padding_left=30
  icon.padding_right=5
  icon.color=$GREY
  icon.highlight_color=$BLACK
  label.drawing=off
  script="$PLUGIN_DIR/spotify.sh"
  y_offset=-45
)

spotify_back=(
  icon=󰙤
  icon.font="$CONTROL_FONT"
  icon.padding_left=5
  icon.padding_right=5
  icon.color=$BLACK
  script="$PLUGIN_DIR/spotify.sh"
  label.drawing=off
  y_offset=-45
)

spotify_play=(
  icon=
  align=center
  icon.font="$CONTROL_FONT"
  icon.padding_left=4
  icon.padding_right=5
  icon.color=$BLACK
  updates=on
  label.drawing=off
  script="$PLUGIN_DIR/spotify.sh"
  y_offset=-45
)

spotify_next=(
  icon=󰙢
  icon.font="$CONTROL_FONT"
  icon.padding_left=5
  icon.padding_right=5
  icon.color=$BLACK
  label.drawing=off
  script="$PLUGIN_DIR/spotify.sh"
  y_offset=-45
)

spotify_repeat=(
  icon.font="$REPEAT_CONTROL_FONT"
  icon=󰑖 # 󰕇
  icon.highlight_color=$BLACK
  icon.padding_left=5
  icon.padding_right=30
  icon.color=$GREY
  label.drawing=off
  script="$PLUGIN_DIR/spotify.sh"
  y_offset=-45
)

spotify_controls=(
  background.color=$GREEN
  background.corner_radius=6
  background.drawing=on
  padding_left=25
  padding_right=25
  y_offset=-45
)

sketchybar --add event spotify_change $SPOTIFY_EVENT             \
           --add item spotify.anchor right                       \
           --set spotify.anchor "${spotify_anchor[@]}"           \
           --subscribe spotify.anchor mouse.clicked              \
                       mouse.exited.global                       \
                                                                 \
           --add item spotify.cover popup.spotify.anchor         \
           --set spotify.cover "${spotify_cover[@]}"             \
                                                                 \
           --add item spotify.title popup.spotify.anchor         \
           --set spotify.title "${spotify_title[@]}"             \
                                                                 \
           --add item spotify.artist popup.spotify.anchor        \
           --set spotify.artist "${spotify_artist[@]}"           \
                                                                 \
           --add item spotify.album popup.spotify.anchor         \
           --set spotify.album "${spotify_album[@]}"             \
                                                                 \
           --add slider spotify.state popup.spotify.anchor       \
           --set spotify.state "${spotify_state[@]}"             \
           --subscribe spotify.state mouse.clicked               \
                                                                 \
           --add item spotify.shuffle popup.spotify.anchor       \
           --set spotify.shuffle "${spotify_shuffle[@]}"         \
           --subscribe spotify.shuffle mouse.clicked             \
                                                                 \
           --add item spotify.back popup.spotify.anchor          \
           --set spotify.back "${spotify_back[@]}"               \
           --subscribe spotify.back mouse.clicked                \
                                                                 \
           --add item spotify.play popup.spotify.anchor          \
           --set spotify.play "${spotify_play[@]}"               \
           --subscribe spotify.play mouse.clicked spotify_change \
                                                                 \
           --add item spotify.next popup.spotify.anchor          \
           --set spotify.next "${spotify_next[@]}"               \
           --subscribe spotify.next mouse.clicked                \
                                                                 \
           --add item spotify.repeat popup.spotify.anchor        \
           --set spotify.repeat "${spotify_repeat[@]}"           \
           --subscribe spotify.repeat  mouse.clicked             \
                                                                 \
           --add item spotify.spacer popup.spotify.anchor        \
           --set spotify.spacer width=5                          \
                                                                 \
           --add bracket spotify.controls spotify.shuffle        \
                                          spotify.back           \
                                          spotify.play           \
                                          spotify.next           \
                                          spotify.repeat         \
           --set spotify.controls "${spotify_controls[@]}"       
