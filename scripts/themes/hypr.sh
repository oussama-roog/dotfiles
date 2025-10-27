#!/usr/bin/env bash

apply_hypr_theme() {
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
}

reload_hypr() {
    hyprctl reload 2>/dev/null || true
}
