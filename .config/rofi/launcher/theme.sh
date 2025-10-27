#!/usr/bin/env bash

dir="$HOME/dotfiles/.config/rofi/launcher"
theme='style'
script="$HOME/dotfiles/scripts/theme-switcher.sh"

themes=$("$script" list)

if [[ -z "$themes" ]]; then
    notify-send "Theme Switcher" "No themes found" -u critical
    exit 1
fi

current_theme=$("$script" current)

chosen=$(echo "$themes" | rofi -dmenu -i -p "Theme" \
    -theme "${dir}/${theme}.rasi" \
    -mesg "Current: $current_theme")

if [[ -n "$chosen" ]]; then
    "$script" apply "$chosen"
fi
