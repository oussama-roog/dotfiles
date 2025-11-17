#!/usr/bin/env bash

apply_dunst_theme() {
    cat >"$CONFIG_DIR/dunst/dunstrc" <<EOF
[global]
    font = JetBrainsMono Nerd Font Propo 12
    width = (300, 500)
    height = 300
    corner_radius = 10
    frame_width = 2
    gap_size = 5
    padding = 15
    horizontal_padding = 25
    origin = top-right
    offset = 10x10
    follow = mouse

[urgency_low]
    background = "#${colors[base00]}"
    foreground = "#${colors[base05]}"
    frame_color = "#${colors[base03]}"
    timeout = 5

[urgency_normal]
    background = "#${colors[base00]}"
    foreground = "#${colors[base05]}"
    frame_color = "#${colors[base0A]}"
    timeout = 10

[urgency_critical]
    background = "#${colors[base08]}"
    foreground = "#${colors[base05]}"
    frame_color = "#${colors[base08]}"
    timeout = 0
EOF
}

reload_dunst() {
    pkill dunst 2>/dev/null
    sleep 0.2
    dunst &
}
