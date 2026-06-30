#!/usr/bin/env bash

dir="$HOME/.config/rofi/wallpaper"
theme='style'
wallpaper_dir="$HOME/dotfiles/wallpapers"

wallpapers=()

for wallpaper in "$wallpaper_dir"/*.{png,jpg,jpeg}; do
    if [[ -f "$wallpaper" ]]; then
        wallpapers+=("$wallpaper")
    fi
done

if [[ ${#wallpapers[@]} -eq 0 ]]; then
    notify-send "No wallpapers found" "Add images to $wallpaper_dir"
    exit 1
fi

rofi_cmd() {
    {
        printf '⚄ Random\n'
        for wallpaper in "${wallpapers[@]}"; do
            printf '%s\x00icon\x1f%s\n' "$wallpaper" "$wallpaper"
        done
    } | rofi -dmenu \
        -p "Wallpaper" \
        -theme ${dir}/${theme}.rasi \
        -show-icons
}

chosen="$(rofi_cmd)"

if [[ -n "$chosen" ]]; then
    if [[ "$chosen" == "⚄ Random" ]]; then
        random_index=$((RANDOM % ${#wallpapers[@]}))
        chosen="${wallpapers[$random_index]}"
    fi
    
    if command -v awww &>/dev/null; then
        awww img "$chosen" --transition-type fade --transition-fps 60
        echo "$chosen" > "$HOME/.cache/current_wallpaper"
        notify-send "Wallpaper Changed" "$(basename "$chosen")"
    else
        notify-send "Error" "awww not found"
    fi
fi
