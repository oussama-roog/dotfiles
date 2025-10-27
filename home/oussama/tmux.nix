{ pkgs, ... }:

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
      
      source-file ~/.config/tmux/colors.conf
      
      set -g status-style "bg=$base01,fg=$base05"
      set -g status-left "#[bg=$base0A,fg=$base00,bold] #S "
      set -g status-right "#[bg=$base03,fg=$base05] %Y-%m-%d %H:%M "
      set -g window-status-current-format "#[bg=$base0A,fg=$base00,bold] #I:#W "
      set -g window-status-format "#[bg=$base02,fg=$base04] #I:#W "
      set -g pane-border-style "fg=$base03"
      set -g pane-active-border-style "fg=$base0A"
      set -g message-style "bg=$base01,fg=$base05"
      
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
