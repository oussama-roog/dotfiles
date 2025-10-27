#!/usr/bin/env bash

apply_gtk_theme() {
    cat > "$CONFIG_DIR/gtk-3.0/gtk.css" << EOF
@define-color theme_bg_color #${colors[base00]};
@define-color theme_fg_color #${colors[base05]};
@define-color theme_base_color #${colors[base00]};
@define-color theme_text_color #${colors[base05]};
@define-color theme_selected_bg_color #${colors[base0D]};
@define-color theme_selected_fg_color #${colors[base00]};
@define-color insensitive_bg_color #${colors[base02]};
@define-color insensitive_fg_color #${colors[base03]};
@define-color insensitive_base_color #${colors[base00]};
@define-color borders #${colors[base03]};
@define-color warning_color #${colors[base09]};
@define-color error_color #${colors[base08]};
@define-color success_color #${colors[base0B]};

* {
    background-color: #${colors[base00]};
    color: #${colors[base05]};
}

window {
    background-color: #${colors[base00]};
    color: #${colors[base05]};
}
EOF

    cp "$CONFIG_DIR/gtk-3.0/gtk.css" "$CONFIG_DIR/gtk-4.0/gtk.css"
}
