#!/usr/bin/env bash

wallpaper_dir="$HOME/dotfiles/wallpapers"

# Use find to pass absolute file paths to vicinae dmenu for quick look preview
chosen=$(find "$wallpaper_dir" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | vicinae dmenu -p 'Pick a wallpaper...')

if [[ -n "$chosen" ]]; then
    # Apply wallpaper
    if command -v swww &>/dev/null; then
        swww img "$chosen" --transition-type fade --transition-fps 60
        echo "$chosen" > "$HOME/.cache/current_wallpaper"
        notify-send "Wallpaper Changed" "$(basename "$chosen")"
    else
        notify-send "Error" "swww not found"
    fi
fi
