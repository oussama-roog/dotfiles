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

themes_with_random="🎲 Random
$themes"

chosen=$(echo "$themes_with_random" | rofi -dmenu -i -p "Theme" \
    -theme "${dir}/${theme}.rasi" \
    -mesg "Current: $current_theme | Themes: $theme_count" \
    -filter "")

if [[ -n "$chosen" ]]; then
    if [[ "$chosen" == "🎲 Random" ]]; then
        "$script" random
    else
        "$script" apply "$chosen"
    fi
fi
