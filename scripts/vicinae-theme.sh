#!/usr/bin/env bash

script="$HOME/dotfiles/scripts/theme-switcher.sh"

# Show loading notification
notify-send "Theme Switcher" "Loading themes..." -t 0 -p > /tmp/theme-loading-notification-id

# Get list of themes
themes=$("$script" list)

# Dismiss loading notification
if [[ -f /tmp/theme-loading-notification-id ]]; then
    notification_id=$(cat /tmp/theme-loading-notification-id)
    notify-send -r "$notification_id" -t 1 "Theme Switcher" "Themes loaded"
    rm /tmp/theme-loading-notification-id
fi

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
