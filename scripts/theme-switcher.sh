#!/usr/bin/env bash

DOTFILES="$HOME/dotfiles"
CONFIG_DIR="$DOTFILES/.config"
CACHE_DIR="$HOME/.cache/theme-switcher"
CURRENT_THEME_FILE="$CACHE_DIR/current-theme"
THEMES_DIR="$DOTFILES/scripts/themes"

mkdir -p "$CACHE_DIR"

get_base16_dir() {
    nix eval --raw nixpkgs#base16-schemes.outPath 2>/dev/null
}

get_themes() {
    local base16_dir=$(get_base16_dir)
    if [[ -n "$base16_dir" && -d "$base16_dir/share/themes" ]]; then
        find "$base16_dir/share/themes" -name "*.yaml" -exec basename {} .yaml \; | sort
    fi
}

parse_yaml_color() {
    local file="$1"
    local key="$2"
    grep "^  $key:" "$file" | sed -E 's/^  [^:]+: *"?#?([0-9a-fA-F]{6})"?.*/\1/' | head -1
}

apply_theme() {
    local theme_name="$1"
    local base16_dir=$(get_base16_dir)
    local theme_file="$base16_dir/share/themes/$theme_name.yaml"

    if [[ ! -f "$theme_file" ]]; then
        echo "Error: Theme file not found: $theme_file"
        exit 1
    fi

    declare -A colors
    for key in base00 base01 base02 base03 base04 base05 base06 base07 base08 base09 base0A base0B base0C base0D base0E base0F; do
        colors[$key]=$(parse_yaml_color "$theme_file" "$key")
    done

    source "$THEMES_DIR/hypr.sh"
    source "$THEMES_DIR/nix.sh"
    source "$THEMES_DIR/waybar.sh"
    source "$THEMES_DIR/rofi.sh"
    source "$THEMES_DIR/kitty.sh"
    source "$THEMES_DIR/ghostty.sh"
    source "$THEMES_DIR/dunst.sh"
    source "$THEMES_DIR/yazi.sh"
    source "$THEMES_DIR/nvim.sh"
    source "$THEMES_DIR/tmux.sh"
    source "$THEMES_DIR/vicinae.sh"

    apply_hypr_theme "${colors[@]}"
    apply_nix_theme "${colors[@]}"
    apply_waybar_theme "${colors[@]}"
    apply_rofi_theme "${colors[@]}"
    apply_kitty_theme "${colors[@]}"
    apply_ghostty_theme "${colors[@]}"
    apply_dunst_theme "${colors[@]}"
    apply_yazi_theme "${colors[@]}"
    apply_nvim_theme "$theme_name"
    apply_vicinae_theme "$theme_name"

    reload_hypr
    reload_waybar
    reload_dunst
    reload_nvim "$theme_name"

    echo "$theme_name" >"$CURRENT_THEME_FILE"

    notify-send "Theme Switcher" "Applied theme: $theme_name" -t 3000
}

case "$1" in
list)
    get_themes
    ;;
apply)
    if [[ -z "$2" ]]; then
        echo "Usage: $0 apply <theme-name>"
        exit 1
    fi
    apply_theme "$2"
    ;;
current)
    if [[ -f "$CURRENT_THEME_FILE" ]]; then
        cat "$CURRENT_THEME_FILE"
    else
        echo "black-metal-bathory"
    fi
    ;;
random)
    themes=($(get_themes))
    if [[ ${#themes[@]} -eq 0 ]]; then
        echo "Error: No themes available"
        exit 1
    fi
    random_theme="${themes[$RANDOM % ${#themes[@]}]}"
    apply_theme "$random_theme"
    ;;
*)
    echo "Usage: $0 {list|apply <theme>|current|random}"
    exit 1
    ;;
esac
