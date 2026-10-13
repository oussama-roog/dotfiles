#!/usr/bin/env bash

# Colours live outside the nix-built tmux.conf (which just sources this file),
# so switching themes never needs a rebuild.

TMUX_COLORS="$HOME/.config/tmux/colors.conf"

apply_tmux_theme() {
    mkdir -p "$(dirname "$TMUX_COLORS")"
    cat >"$TMUX_COLORS" <<EOF
# Base16 colors for tmux — managed by theme-switcher
set -g status-style "bg=#${colors[base01]},fg=#${colors[base05]}"
set -g status-left "#{?client_prefix,#[bg=#${colors[base08]}],#[bg=#${colors[base0A]}]}#[fg=#${colors[base00]},bold] #S #[fg=#${colors[base0A]},bg=#${colors[base01]}]      "
set -g status-right "#[bg=#${colors[base03]},fg=#${colors[base05]}] %Y-%m-%d %H:%M "
set -g window-status-current-format "#[bg=#${colors[base0A]},fg=#${colors[base00]},bold] #I:#W "
set -g window-status-format "#[bg=#${colors[base02]},fg=#${colors[base04]}] #I:#W "
set -g pane-border-style "fg=#${colors[base03]}"
set -g pane-active-border-style "fg=#${colors[base0A]}"
set -g message-style "bg=#${colors[base01]},fg=#${colors[base05]}"
EOF
}

reload_tmux() {
    tmux source-file "$TMUX_COLORS" 2>/dev/null || true
}
