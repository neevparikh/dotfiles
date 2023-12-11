#!/bin/bash

get_layout_type() {
  out=$(yabai -m query --spaces --window mouse)
  length=$(echo $out | jq length)
  if [ -z "$length" ] || [ $length -ne 1 ]; then 
    return -1
  fi
  echo $(echo $out | jq --raw-output ".[0].type")
}

get_opposite_dir() {
  direction=$1
  case $direction in
  north)
    echo "south";;
  south)
    echo "north";;
  east)
    echo "west";;
  west)
    echo "east";;
  *)
    exit -1;;
  esac
}

yabai_move_to_desktop() {
  direction=$1
  opposite=$(get_opposite_dir $direction)

  if ! yabai -m query --displays --display $direction ; then
    return 1
  fi

  src=$(yabai -m query --windows --window | jq '.id')
  dst=$(yabai -m query --windows --display $direction | jq 'map(select(."is-visible" == true))' | jq '.id?')
  if [ -z "$dst" ]; then 
    yabai -m window $src --display $direction
  else 
    yabai -m window $dst --insert $opposite                                              \
        && yabai -m window --focus $src                                                  \
        && yabai -m window --warp $dst                                                   
  fi
  yabai -m window --focus $src                                                  
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
      yabai -m window --warp $direction || yabai_move_to_desktop $direction
  else
    return -1
  fi
} 
