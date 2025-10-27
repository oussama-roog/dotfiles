#!/usr/bin/env bash

DOTFILES="$HOME/dotfiles"
CONFIG_DIR="$DOTFILES/.config"
CACHE_DIR="$HOME/.cache/theme-switcher"
CURRENT_THEME_FILE="$CACHE_DIR/current-theme"

mkdir -p "$CACHE_DIR"

get_base16_dir() {
    nix-build -E 'with import <nixpkgs> {}; base16-schemes' 2>/dev/null | tr -d '\n'
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
    
    cat > "$CONFIG_DIR/hypr/colors.conf" << EOF
\$base00 = ${colors[base00]}ff
\$base01 = ${colors[base01]}ff
\$base02 = ${colors[base02]}ff
\$base03 = ${colors[base03]}ff
\$base04 = ${colors[base04]}ff
\$base05 = ${colors[base05]}ff
\$base06 = ${colors[base06]}ff
\$base07 = ${colors[base07]}ff
\$base08 = ${colors[base08]}ff
\$base09 = ${colors[base09]}ff
\$base0A = ${colors[base0A]}ff
\$base0B = ${colors[base0B]}ff
\$base0C = ${colors[base0C]}ff
\$base0D = ${colors[base0D]}ff
\$base0E = ${colors[base0E]}ff
\$base0F = ${colors[base0F]}ff
EOF
    
    cat > "$DOTFILES/home/oussama/colors.nix" << EOF
{
  base00 = "#${colors[base00]}";
  base01 = "#${colors[base01]}";
  base02 = "#${colors[base02]}";
  base03 = "#${colors[base03]}";
  base04 = "#${colors[base04]}";
  base05 = "#${colors[base05]}";
  base06 = "#${colors[base06]}";
  base07 = "#${colors[base07]}";
  base08 = "#${colors[base08]}";
  base09 = "#${colors[base09]}";
  base0A = "#${colors[base0A]}";
  base0B = "#${colors[base0B]}";
  base0C = "#${colors[base0C]}";
  base0D = "#${colors[base0D]}";
  base0E = "#${colors[base0E]}";
  base0F = "#${colors[base0F]}";
}
EOF
    
    cat > "$CONFIG_DIR/waybar/colors.css" << EOF
@define-color base00 #${colors[base00]};
@define-color base01 #${colors[base01]};
@define-color base02 #${colors[base02]};
@define-color base03 #${colors[base03]};
@define-color base04 #${colors[base04]};
@define-color base05 #${colors[base05]};
@define-color base06 #${colors[base06]};
@define-color base07 #${colors[base07]};
@define-color base08 #${colors[base08]};
@define-color base09 #${colors[base09]};
@define-color base0A #${colors[base0A]};
@define-color base0B #${colors[base0B]};
@define-color base0C #${colors[base0C]};
@define-color base0D #${colors[base0D]};
@define-color base0E #${colors[base0E]};
@define-color base0F #${colors[base0F]};
EOF
    
    cat > "$CONFIG_DIR/rofi/colors.rasi" << EOF
* {
    base00: #${colors[base00]};
    base01: #${colors[base01]};
    base02: #${colors[base02]};
    base03: #${colors[base03]};
    base04: #${colors[base04]};
    base05: #${colors[base05]};
    base06: #${colors[base06]};
    base07: #${colors[base07]};
    base08: #${colors[base08]};
    base09: #${colors[base09]};
    base0A: #${colors[base0A]};
    base0B: #${colors[base0B]};
    base0C: #${colors[base0C]};
    base0D: #${colors[base0D]};
    base0E: #${colors[base0E]};
    base0F: #${colors[base0F]};

    background:     @base00;
    background-alt: @base01;
    foreground:     @base05;
    selected:       @base0A;
    active:         @base0B;
    urgent:         @base08;
}
EOF
    
    cat > "$CONFIG_DIR/kitty/colors.conf" << EOF
background #${colors[base00]}
foreground #${colors[base05]}
selection_background #${colors[base05]}
selection_foreground #${colors[base00]}

cursor #${colors[base05]}
cursor_text_color #${colors[base00]}

color0 #${colors[base00]}
color1 #${colors[base08]}
color2 #${colors[base0B]}
color3 #${colors[base0A]}
color4 #${colors[base0D]}
color5 #${colors[base0E]}
color6 #${colors[base0C]}
color7 #${colors[base05]}

color8 #${colors[base03]}
color9 #${colors[base08]}
color10 #${colors[base0B]}
color11 #${colors[base0A]}
color12 #${colors[base0D]}
color13 #${colors[base0E]}
color14 #${colors[base0C]}
color15 #${colors[base05]}
EOF
    
    cat > "$CONFIG_DIR/dunst/dunstrc" << EOF
[global]
    frame_color = "#${colors[base0A]}"
[urgency_low]
    background = "#${colors[base00]}"
    foreground = "#${colors[base05]}"
    frame_color = "#${colors[base03]}"
    timeout = 5
    icon = dialog-information

[urgency_normal]
    background = "#${colors[base00]}"
    foreground = "#${colors[base05]}"
    frame_color = "#${colors[base0A]}"
    timeout = 10
    icon = dialog-information

[urgency_critical]
    background = "#${colors[base08]}"
    foreground = "#${colors[base05]}"
    frame_color = "#${colors[base08]}"
    timeout = 0
    icon = dialog-error
EOF
    
    cat > "$CONFIG_DIR/yazi/theme.toml" << EOF
[mgr]
cwd = { fg = "#${colors[base05]}" }
hovered = { bg = "#${colors[base02]}" }
find_keyword = { fg = "#${colors[base0A]}", bold = true }
marker_copied = { bg = "#${colors[base0B]}" }
marker_cut = { bg = "#${colors[base0A]}" }
tab_active = { fg = "#${colors[base05]}", bold = true }
tab_inactive = { fg = "#${colors[base04]}" }
border_style = { fg = "#${colors[base03]}" }

[mode]
normal_main = { fg = "#${colors[base05]}", bg = "#${colors[base00]}" }
select_main = { fg = "#${colors[base05]}", bg = "#${colors[base02]}" }

[status]
overall = { fg = "#${colors[base05]}", bg = "#${colors[base00]}" }
perm_type = { fg = "#${colors[base0D]}" }
perm_read = { fg = "#${colors[base0B]}" }
perm_write = { fg = "#${colors[base0A]}" }
perm_exec = { fg = "#${colors[base08]}" }
progress_normal = { fg = "#${colors[base05]}", bg = "#${colors[base01]}" }
progress_error = { fg = "#${colors[base08]}" }

[pick]
border = { fg = "#${colors[base03]}" }
active = { fg = "#${colors[base05]}", bg = "#${colors[base02]}" }
inactive = { fg = "#${colors[base05]}" }

[input]
border = { fg = "#${colors[base03]}" }
value = { fg = "#${colors[base05]}" }
selected = { bg = "#${colors[base02]}" }

[cmp]
border = { fg = "#${colors[base03]}" }
active = { fg = "#${colors[base05]}", bg = "#${colors[base02]}" }
inactive = { fg = "#${colors[base05]}" }

[tasks]
border = { fg = "#${colors[base03]}" }
hovered = { bg = "#${colors[base02]}" }

[help]
on = { fg = "#${colors[base0D]}" }
desc = { fg = "#${colors[base05]}" }
hovered = { bg = "#${colors[base02]}" }

[notify]
title_info = { fg = "#${colors[base0D]}" }
title_warn = { fg = "#${colors[base0A]}" }
title_error = { fg = "#${colors[base08]}" }

[filetype]
rules = [
        { name = "*/", fg = "#${colors[base0D]}" },
        { name = "*", fg = "#${colors[base05]}" }
]

EOF

    cat > "$CONFIG_DIR/gtk-3.0/gtk.css" << EOF
@define-color theme_fg_color #${colors[base05]};
@define-color theme_bg_color #${colors[base00]};
@define-color theme_base_color #${colors[base00]};
@define-color theme_selected_bg_color #${colors[base0D]};
@define-color theme_selected_fg_color #${colors[base00]};
@define-color insensitive_bg_color #${colors[base01]};
@define-color insensitive_fg_color #${colors[base03]};
@define-color insensitive_base_color #${colors[base01]};
@define-color theme_unfocused_fg_color #${colors[base04]};
@define-color theme_unfocused_bg_color #${colors[base01]};
@define-color theme_unfocused_base_color #${colors[base01]};
@define-color theme_unfocused_selected_bg_color #${colors[base0D]};
@define-color theme_unfocused_selected_fg_color #${colors[base00]};
@define-color borders #${colors[base03]};
@define-color unfocused_borders #${colors[base02]};

* {
    background-color: #${colors[base00]};
    color: #${colors[base05]};
}

window {
    background-color: #${colors[base00]};
}

.background {
    background-color: #${colors[base00]};
    color: #${colors[base05]};
}
EOF

    cp "$CONFIG_DIR/gtk-3.0/gtk.css" "$CONFIG_DIR/gtk-4.0/gtk.css"
    
    cat > "$CONFIG_DIR/ghostty/config" << EOF
font-size = 14

background = ${colors[base00]}
foreground = ${colors[base05]}
selection-background = ${colors[base05]}
selection-foreground = ${colors[base00]}

cursor-color = ${colors[base05]}

palette = 0=#${colors[base00]}
palette = 1=#${colors[base08]}
palette = 2=#${colors[base0B]}
palette = 3=#${colors[base0A]}
palette = 4=#${colors[base0D]}
palette = 5=#${colors[base0E]}
palette = 6=#${colors[base0C]}
palette = 7=#${colors[base05]}
palette = 8=#${colors[base03]}
palette = 9=#${colors[base08]}
palette = 10=#${colors[base0B]}
palette = 11=#${colors[base0A]}
palette = 12=#${colors[base0D]}
palette = 13=#${colors[base0E]}
palette = 14=#${colors[base0C]}
palette = 15=#${colors[base05]}
EOF
    
    if pgrep -x ghostty > /dev/null; then
        killall -SIGUSR2 ghostty 2>/dev/null
    fi
    
    cat > "$CONFIG_DIR/nvim/lua/oussama/plugins/colorscheme.lua" << EOF
return {
	{
		"tinted-theming/tinted-vim",
		config = function()
			vim.cmd.colorscheme("base16-$theme_name")
		end,
	},
}
EOF
    
    if command -v tmux >/dev/null 2>&1; then
        tmux source-file ~/.tmux.conf 2>/dev/null || true
    fi
    
    if pgrep -x waybar > /dev/null; then
        killall -SIGUSR2 waybar 2>/dev/null
    fi
    
    hyprctl reload 2>/dev/null || true
    
    if pgrep -x dunst > /dev/null; then
        killall dunst 2>/dev/null
        dunst & disown
    fi
    
    echo "$theme_name" > "$CURRENT_THEME_FILE"
    
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
    *)
        echo "Usage: $0 {list|apply <theme>|current}"
        exit 1
        ;;
esac
