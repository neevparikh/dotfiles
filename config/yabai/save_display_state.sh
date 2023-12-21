#!/bin/bash

yabai -m query --displays | jq -r --argjson display $1 '. | map(select(.id == $display)) | .[] | .index' > /tmp/yabai_display_index
