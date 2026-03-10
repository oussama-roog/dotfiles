#!/usr/bin/env bash

apply_i3_theme() {
    cat > "$CONFIG_DIR/i3/colors" << EOF
# Base16 colors for i3 — managed by theme-switcher
set \$base00 #${colors[base00]}
set \$base01 #${colors[base01]}
set \$base02 #${colors[base02]}
set \$base03 #${colors[base03]}
set \$base04 #${colors[base04]}
set \$base05 #${colors[base05]}
set \$base06 #${colors[base06]}
set \$base07 #${colors[base07]}
set \$base08 #${colors[base08]}
set \$base09 #${colors[base09]}
set \$base0A #${colors[base0A]}
set \$base0B #${colors[base0B]}
set \$base0C #${colors[base0C]}
set \$base0D #${colors[base0D]}
set \$base0E #${colors[base0E]}
set \$base0F #${colors[base0F]}

# class                 border  backgr  text    indicator child_border
client.focused          \$base0A \$base0A \$base00 \$base0B   \$base0A
client.focused_tab_title \$base02 \$base02 \$base05
client.focused_inactive \$base02 \$base02 \$base05 \$base03   \$base02
client.unfocused        \$base01 \$base01 \$base04 \$base01   \$base01
client.urgent           \$base08 \$base08 \$base07 \$base08   \$base08
client.placeholder      \$base00 \$base00 \$base05 \$base00   \$base00
client.background       \$base00
EOF
}

reload_i3() {
    i3-msg reload 2>/dev/null || true
}
