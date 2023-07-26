# sketchybar --add alias "Control Center,WiFi" right      \
#            --set "Control Center,WiFi" width=20         \
#                       scale=0.7                         \
#                       padding_left=0                    \
#                       alias.update_freq=60

# sketchybar --add alias "Control Center,Bluetooth" right \
#            --set "Control Center,Bluetooth" width=23    \
#                       scale=0.7                         \
#                       padding_left=10                   \
#                       padding_right=10                  \
#                       alias.update_freq=60

sketchybar --add alias "MeetingBar,Item-0" right          \
           --set "MeetingBar,Item-0"                      \
                      alias.color=$YELLOW                 \
                      alias.update_freq=60                \
                      alias.scale=1                       \
                      icon.font="$FONT:Retina:12.0"       \
                      icon.padding_right=3                \
                      icon.color=$YELLOWALT               \
                      icon.y_offset=2                     \
                      label.y_offset=1                    \
                      label.font="$FONT:Bold:12"          \
                      label.color=$YELLOW                 \
                      label.padding_right=0               \
                      background.color=$YELLOW            \
                      background.height=2                 \
                      background.y_offset=-9              \
                      background.padding_right=8       
