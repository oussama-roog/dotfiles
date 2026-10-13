#!/usr/bin/env bash

DOTFILES="$HOME/dotfiles"
CONFIG_DIR="$DOTFILES/.config"
CACHE_DIR="$HOME/.cache/theme-switcher"
CURRENT_THEME_FILE="$CACHE_DIR/current-theme"
THEMES_DIR="$DOTFILES/scripts/themes"

mkdir -p "$CACHE_DIR"

# base16-schemes is installed in the user profile; nix eval is only a fallback
get_themes_dir() {
    local dir
    for dir in "/etc/profiles/per-user/$USER/share/themes" "$HOME/.nix-profile/share/themes"; do
        if compgen -G "$dir/*.yaml" >/dev/null; then
            echo "$dir"
            return
        fi
    done
    local out
    out=$(nix eval --raw nixpkgs#base16-schemes.outPath 2>/dev/null) && echo "$out/share/themes"
}

get_themes() {
    local themes_dir=$(get_themes_dir)
    if [[ -n "$themes_dir" ]]; then
        find -L "$themes_dir" -maxdepth 1 -name "*.yaml" -exec basename {} .yaml \; | sort
    fi
}

parse_yaml_color() {
    local file="$1"
    local key="$2"
    grep "^  $key:" "$file" | sed -E 's/^  [^:]+: *"?#?([0-9a-fA-F]{6})"?.*/\1/' | head -1
}

current_theme() {
    cat "$CURRENT_THEME_FILE" 2>/dev/null || echo "black-metal-bathory"
}

apply_theme() {
    local theme_name="$1"
    local theme_file="$(get_themes_dir)/$theme_name.yaml"

    if [[ ! -f "$theme_file" ]]; then
        echo "Error: Theme file not found: $theme_file"
        exit 1
    fi

    declare -A colors
    for key in base00 base01 base02 base03 base04 base05 base06 base07 base08 base09 base0A base0B base0C base0D base0E base0F; do
        colors[$key]=$(parse_yaml_color "$theme_file" "$key")
    done

    source "$THEMES_DIR/hypr.sh"
    source "$THEMES_DIR/rofi.sh"
    source "$THEMES_DIR/kitty.sh"
    source "$THEMES_DIR/ghostty.sh"
    source "$THEMES_DIR/dunst.sh"
    source "$THEMES_DIR/yazi.sh"
    source "$THEMES_DIR/nvim.sh"
    source "$THEMES_DIR/tmux.sh"
    source "$THEMES_DIR/vicinae.sh"
    source "$THEMES_DIR/i3.sh"
    source "$THEMES_DIR/polybar.sh"
    source "$THEMES_DIR/quickshell.sh"
    source "$THEMES_DIR/gtk.sh"

    apply_hypr_theme "${colors[@]}" # hyprlock colors
    apply_rofi_theme "${colors[@]}"
    apply_kitty_theme "${colors[@]}"
    apply_ghostty_theme "${colors[@]}"
    apply_dunst_theme "${colors[@]}"
    apply_yazi_theme "${colors[@]}"
    apply_nvim_theme "$theme_name"
    apply_vicinae_theme "$theme_name"
    apply_i3_theme "${colors[@]}"
    apply_polybar_theme "${colors[@]}"
    apply_quickshell_theme
    apply_tmux_theme
    apply_gtk_theme

    reload_kitty
    reload_ghostty
    reload_tmux
    reload_dunst
    reload_nvim "$theme_name"
    reload_i3
    reload_polybar

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
    current_theme
    ;;
restore)
    apply_theme "$(current_theme)"
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
    echo "Usage: $0 {list|apply <theme>|current|restore|random}"
    exit 1
    ;;
esac
