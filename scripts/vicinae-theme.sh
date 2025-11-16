#!/usr/bin/env bash

script="$HOME/dotfiles/scripts/theme-switcher.sh"

# Get list of themes
themes=$("$script" list)

if [[ -z "$themes" ]]; then
    notify-send "Theme Switcher" "No themes found" -u critical
    exit 1
fi

# Get current theme info
current_theme=$("$script" current)
theme_count=$(echo "$themes" | wc -l)

# Add random option at the top
themes_with_random="🎲 Random"$'\n'"$themes"

# Use vicinae dmenu to show themes
chosen=$(echo -n "$themes_with_random" | vicinae dmenu --placeholder "Select Theme (Current: $current_theme | Total: $theme_count)")

if [[ -n "$chosen" ]]; then
    if [[ "$chosen" == "🎲 Random" ]]; then
        "$script" random
    else
        "$script" apply "$chosen"
    fi
fi
