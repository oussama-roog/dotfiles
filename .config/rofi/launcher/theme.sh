#!/usr/bin/env bash

dir="$HOME/dotfiles/.config/rofi/launcher"
theme='style'
script="$HOME/dotfiles/scripts/theme-switcher.sh"

rofi -e "Loading themes..." -theme "${dir}/${theme}.rasi" &
rofi_pid=$!

themes=$("$script" list)

kill $rofi_pid 2>/dev/null

if [[ -z "$themes" ]]; then
    notify-send "Theme Switcher" "No themes found" -u critical
    exit 1
fi

current_theme=$("$script" current)
theme_count=$(echo "$themes" | wc -l)

chosen=$(echo "$themes" | rofi -dmenu -i -p "Theme" \
    -theme "${dir}/${theme}.rasi" \
    -mesg "Current: $current_theme | Themes: $theme_count")

if [[ -n "$chosen" ]]; then
    "$script" apply "$chosen"
fi
