#!/usr/bin/env bash

# Recolours adw-gtk3 (GTK3) and libadwaita (GTK4) through their named colours,
# the same way Ambxst does it. Flipping gtk-theme in dconf makes running apps
# re-read gtk.css; on X11 without an xsettings daemon only new windows change.

apply_gtk_theme() {
    local bg="${colors[base00]}"
    local brightness=$(( (16#${bg:0:2} * 299 + 16#${bg:2:2} * 587 + 16#${bg:4:2} * 114) / 1000 ))
    local dark=1 scheme="prefer-dark" gtk_theme="adw-gtk3-dark"
    if (( brightness > 128 )); then
        dark=0 scheme="prefer-light" gtk_theme="adw-gtk3"
    fi

    local css
    css=$(cat <<EOF
/* Base16 colors for GTK — managed by theme-switcher */
@define-color accent_color #${colors[base0D]};
@define-color accent_bg_color #${colors[base0D]};
@define-color accent_fg_color #${colors[base00]};
@define-color destructive_color #${colors[base08]};
@define-color destructive_bg_color #${colors[base08]};
@define-color destructive_fg_color #${colors[base00]};
@define-color success_color #${colors[base0B]};
@define-color warning_color #${colors[base0A]};
@define-color error_color #${colors[base08]};
@define-color window_bg_color #${colors[base00]};
@define-color window_fg_color #${colors[base05]};
@define-color view_bg_color #${colors[base00]};
@define-color view_fg_color #${colors[base05]};
@define-color headerbar_bg_color #${colors[base01]};
@define-color headerbar_fg_color #${colors[base05]};
@define-color headerbar_backdrop_color #${colors[base00]};
@define-color sidebar_bg_color #${colors[base01]};
@define-color sidebar_fg_color #${colors[base05]};
@define-color sidebar_backdrop_color #${colors[base01]};
@define-color card_bg_color #${colors[base01]};
@define-color card_fg_color #${colors[base05]};
@define-color dialog_bg_color #${colors[base01]};
@define-color dialog_fg_color #${colors[base05]};
@define-color popover_bg_color #${colors[base01]};
@define-color popover_fg_color #${colors[base05]};
EOF
)

    local dir
    for dir in "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"; do
        mkdir -p "$dir"
        printf '%s\n' "$css" >"$dir/gtk.css"
    done

    # Read by GTK on X11 (i3) where there's no settings portal
    cat >"$HOME/.config/gtk-3.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=$gtk_theme
gtk-application-prefer-dark-theme=$dark
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=24
EOF
    cat >"$HOME/.config/gtk-4.0/settings.ini" <<EOF
[Settings]
gtk-application-prefer-dark-theme=$dark
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=24
EOF

    # Read through the settings portal on Wayland (niri)
    if command -v dconf >/dev/null 2>&1; then
        dconf write /org/gnome/desktop/interface/color-scheme "'$scheme'"
        dconf write /org/gnome/desktop/interface/gtk-theme "''"
        dconf write /org/gnome/desktop/interface/gtk-theme "'$gtk_theme'"
    fi
}
