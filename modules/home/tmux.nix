{ pkgs, ... }:

let
  colors = import ./colors.nix;
in
{
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    baseIndex = 1;
    escapeTime = 0;
    mouse = true;
    keyMode = "vi";
    prefix = "C-a";

    extraConfig = ''
      set-option -sa terminal-overrides ",xterm*:Tc"
      set-option -g status-position bottom
      set -g renumber-windows on
      
      set -g status-style "bg=${colors.base01},fg=${colors.base05}"
      set -g status-left "#{?client_prefix,#[bg=${colors.base08}],#[bg=${colors.base0A}]}#[fg=${colors.base00},bold] #S #[fg=${colors.base0A},bg=${colors.base01}]      "
      set -g status-right "#[bg=${colors.base03},fg=${colors.base05}] %Y-%m-%d %H:%M "
      set -g window-status-current-format "#[bg=${colors.base0A},fg=${colors.base00},bold] #I:#W "
      set -g window-status-format "#[bg=${colors.base02},fg=${colors.base04}] #I:#W "
      set -g window-status-separator ""
      set -g pane-border-style "fg=${colors.base03}"
      set -g pane-active-border-style "fg=${colors.base0A}"
      set -g message-style "bg=${colors.base01},fg=${colors.base05}"
      set -g status-left-length 100
      
      unbind C-b
      bind-key C-a send-prefix
      
      unbind r
      bind r source-file ~/.tmux.conf
      
      bind -r j resize-pane -D 5
      bind -r k resize-pane -U 5
      bind -r l resize-pane -R 5
      bind -r h resize-pane -L 5
      
      bind -r m resize-pane -Z
      bind e if-shell 'tmux has-session -t oussama' 'kill-session; switch-client -t oussama' 'detach'
      
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'y' send -X copy-selection
      
      unbind -T copy-mode-vi MouseDragEnd1Pane
      
      bind-key -r f run-shell "tmux neww ~/dotfiles/scripts/tmux-sessionizer"
    '';

    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      sensible
      yank
    ];
  };
}
