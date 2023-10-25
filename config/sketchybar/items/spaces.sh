#!/bin/sh

# Spaces
MAIN_DISPLAY_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10")
SECONDARY_DISPLAY_ICONS=("11" "12" "13" "14" "15" "16")
SPACE_ICONS=("${MAIN_DISPLAY_ICONS[@]}" "${SECONDARY_DISPLAY_ICONS[@]}")

# Destroy space on right click, focus space on left click.
# New space by left clicking separator (>)
sketchybar --add event refresh_spaces

sid=0
spaces=()
for i in "${!SPACE_ICONS[@]}"
do
  sid=$(($i+1))
  color="$FG2"
  sketchybar --add space      space.$sid left                               \
             --set space.$sid associated_space=$sid                         \
                              script="$PLUGIN_DIR/space.sh"                 \
                              label.drawing=off                             \
                              label.align=center                            \
                              label.width=10                                \
                              icon=${SPACE_ICONS[i]}                        \
                              icon.width=20                                 \
                              width=25                                      \
                              align=center                                  \
                              icon.align=center                             \
                              icon.y_offset=0                               \
                              icon.font="$FONT:Bold:11.0"                   \
                              icon.color=$color                             \
                              icon.highlight_color=$color                   \
                              icon.background.height=2                      \
                              icon.background.corner_radius=2               \
                              icon.background.color=$FG                  \
                              icon.background.y_offset=-16                  \
                              background.color=$BG                          \
                              background.corner_radius=4                    \
            --subscribe space.$sid mouse.clicked refresh_spaces                             
done

