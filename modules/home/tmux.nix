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

      # Colours are written by scripts/theme-switcher.sh so they change without a rebuild
      source-file -q ~/.config/tmux/colors.conf
      set -g window-status-separator ""
      set -g status-left-length 100
      
      unbind C-b
      bind-key C-a send-prefix
      
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf
      
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

      # Scratchpad popup with a quick agent (scripts/tmux-scratch); same key closes it
      bind-key a run-shell "~/dotfiles/scripts/tmux-scratch claude"
      bind-key A run-shell "~/dotfiles/scripts/tmux-scratch agy"
    '';

    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      sensible
      yank
    ];
  };
}
