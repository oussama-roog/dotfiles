{ config, pkgs, ... }:

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
      
      bind-key -r f run-shell "tmux neww ${config.home.homeDirectory}/dotfiles/.tmux-sessionizer"
      
      bind -r o popup -E -d "#{pane_current_path}" -w 90% -h 90% "bash -c '${config.home.homeDirectory}/.opencode/bin/opencode; exit'"
    '';
    
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      sensible
      yank
      {
        plugin = rose-pine;
        extraConfig = ''
          set -g @rose_pine_variant 'main'
        '';
      }
    ];
  };
}
