#!/usr/bin/env bash

apply_rofi_theme() {
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
}
