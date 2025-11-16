#!/usr/bin/env bash

apply_vicinae_theme() {
    local theme_name="$1"
    local themes_dir="$HOME/.local/share/vicinae/themes"
    local theme_file="$themes_dir/${theme_name}.toml"
    
    mkdir -p "$themes_dir"
    
    # Determine if theme is dark or light based on background brightness
    # Using base00 (background) to determine variant
    local bg_hex="${colors[base00]}"
    local r=$((16#${bg_hex:0:2}))
    local g=$((16#${bg_hex:2:2}))
    local b=$((16#${bg_hex:4:2}))
    local brightness=$(( (r * 299 + g * 587 + b * 114) / 1000 ))
    local variant="dark"
    if [ $brightness -gt 128 ]; then
        variant="light"
    fi
    
    # Create Vicinae theme file in TOML format
    cat > "$theme_file" << EOF
[meta]
version = 1
name = "$theme_name"
description = "Auto-generated from base16 theme: $theme_name"
variant = "$variant"

[colors.core]
background = "#${colors[base00]}"
foreground = "#${colors[base05]}"
secondary_background = "#${colors[base01]}"
border = "#${colors[base03]}"
accent = "#${colors[base0D]}"
accent_foreground = "#${colors[base00]}"

[colors.accents]
blue = "#${colors[base0D]}"
green = "#${colors[base0B]}"
magenta = "#${colors[base0E]}"
orange = "#${colors[base09]}"
red = "#${colors[base08]}"
yellow = "#${colors[base0A]}"
cyan = "#${colors[base0C]}"
purple = "#${colors[base0E]}"

[colors.text]
default = "#${colors[base05]}"
muted = "#${colors[base04]}"
danger = "#${colors[base08]}"
success = "#${colors[base0B]}"
placeholder = "#${colors[base04]}"

[colors.text.selection]
background = "#${colors[base0D]}"
foreground = "#${colors[base00]}"

[colors.text.links]
default = "#${colors[base0D]}"
visited = "#${colors[base0E]}"

[colors.input]
border = "#${colors[base03]}"
border_focus = "#${colors[base0D]}"
border_error = "#${colors[base08]}"

[colors.buttons]
primary_background = "#${colors[base0D]}"
primary_foreground = "#${colors[base00]}"
secondary_background = "#${colors[base02]}"
secondary_foreground = "#${colors[base05]}"

[colors.panel]
background = "#${colors[base01]}"
border = "#${colors[base03]}"

[colors.modal]
background = "#${colors[base01]}"
border = "#${colors[base03]}"
overlay = { name = "#${colors[base00]}", opacity = 0.8 }

[colors.scrollbar]
track = "#${colors[base01]}"
thumb = "#${colors[base03]}"
thumb_hover = "#${colors[base04]}"

[colors.tabs]
background = "#${colors[base01]}"
foreground = "#${colors[base05]}"
active_background = "#${colors[base00]}"
active_foreground = "#${colors[base05]}"
border = "#${colors[base03]}"

[colors.list]
item_hover = "#${colors[base02]}"
item_active = "#${colors[base0D]}"
item_active_foreground = "#${colors[base00]}"

[colors.tooltip]
background = "#${colors[base01]}"
foreground = "#${colors[base05]}"
border = "#${colors[base03]}"

[colors.notification]
background = "#${colors[base01]}"
foreground = "#${colors[base05]}"
border = "#${colors[base03]}"
error_background = "#${colors[base08]}"
error_foreground = "#${colors[base00]}"
success_background = "#${colors[base0B]}"
success_foreground = "#${colors[base00]}"

[colors.search]
match_background = "#${colors[base0A]}"
match_foreground = "#${colors[base00]}"
current_match_background = "#${colors[base09]}"
current_match_foreground = "#${colors[base00]}"
EOF

    # Apply the theme using vicinae command
    if command -v vicinae &> /dev/null; then
        vicinae theme set "$theme_name" 2>/dev/null || true
    fi
}
