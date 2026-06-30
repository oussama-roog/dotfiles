#!/usr/bin/env bash

wallpaper_dir="$HOME/dotfiles/wallpapers"

# Use find to pass absolute file paths to vicinae dmenu for quick look preview
chosen=$(find "$wallpaper_dir" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | vicinae dmenu -p 'Pick a wallpaper...')

if [[ -n "$chosen" ]]; then
    echo "$chosen" > "$HOME/.cache/current_wallpaper"

    if [[ "$XDG_SESSION_TYPE" == "x11" ]]; then
        # X11: use feh
        if command -v feh &>/dev/null; then
            feh --bg-fill "$chosen"
            notify-send "Wallpaper Changed" "$(basename "$chosen")"
        else
            notify-send "Error" "feh not found"
        fi
    else
        # Wayland: use awww
        if command -v awww &>/dev/null; then
            awww img "$chosen" --transition-type fade --transition-fps 60
            notify-send "Wallpaper Changed" "$(basename "$chosen")"
        else
            notify-send "Error" "awww not found"
        fi
    fi
fi

