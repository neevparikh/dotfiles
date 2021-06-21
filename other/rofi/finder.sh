#!/usr/bin/env bash
# This script has been adapted from https://github.com/davatorium/rofi-scripts/blob/master/rofi-finder/finder.sh

ITEM_LIMIT=$(xrescat rofi.search.limit 100)
SHOW_HELP=$(xrescat rofi.search.help "false")

if [ ! -z "$@" ]; then
    # A search parameter was passed from the dialog
    QUERY=$@
    # Manually expand ~ to $HOME, based on https://unix.stackexchange.com/a/399439      
    if [[ $QUERY = "~/"* ]]; then 
        QUERY="${HOME}/${QUERY#"~/"}"
    fi
    # User entered a complete file path, so just launch it
    coproc ( xdg-open "$QUERY"  > /dev/null 2>&1 )
    exec 1>&-
    exit;
else
    # search for things
    fd --follow --hidden --exclude .git --color=never --max-results $ITEM_LIMIT --type directory --type file &
fi
