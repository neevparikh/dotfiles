#!/bin/bash

get_layout_type() {
  out=$(yabai -m query --spaces --window mouse)
  length=$(echo $out | jq length)
  if [ $length -ne 1 ]; then 
    return -1
  fi
  echo $(echo $out | jq --raw-output ".[0].type")
}

yabai_move() {
  direction=$1
  layout=$(get_layout_type)
  if [ "$layout" = "stack" ]; then
    case $direction in
    north)
      yabai -m window --warp stack.prev;; 
    south)
      yabai -m window --warp stack.next;; 
    *)
      :;;
    esac
  elif [ "$layout" = "bsp" ]; then
    case $direction in
    north)
      yabai -m window --warp $direction || yabai -m space --rotate 270;;
    south)
      yabai -m window --warp $direction || yabai -m space --rotate 90;;
    east | west)
      yabai -m window --warp $direction || yabai -m window --toggle split && yabai -m space --balance y-axis;;
    *)
      :;;
    esac
  else
    return -1
  fi
} 
