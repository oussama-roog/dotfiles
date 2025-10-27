#!/usr/bin/env bash

CACHE_DIR="$HOME/.cache/theme-switcher"
CURRENT_THEME_FILE="$CACHE_DIR/current-theme"
SCRIPT_DIR="$HOME/dotfiles/scripts"

if [[ -f "$CURRENT_THEME_FILE" ]]; then
    theme=$(cat "$CURRENT_THEME_FILE")
else
    theme="black-metal-bathory"
fi

"$SCRIPT_DIR/theme-switcher.sh" apply "$theme"
