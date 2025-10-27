#!/usr/bin/env bash

apply_kitty_theme() {
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
}
