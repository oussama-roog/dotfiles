{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    
    shellAliases = {
      v = "nvim";
      y = "yazi";
      ta = "tmux attach-session -t oussama || tmux new-session -s oussama";
      lg = "lazygit";
      op = "tmux-sessionizer";
      data = "sudo mount -t ntfs3 -o umask=000 /dev/nvme0n1p5 /home/oussama/data";
      udata = "sudo umount /home/oussama/data";
      btw = "echo nixos and neovim btw";
    };
    
    initExtra = ''
      eval "$(starship init bash)"
      eval "$(zoxide init bash)"
      
      test -s ~/.alias && . ~/.alias || true

      [ -f ~/.env ] && source ~/.env
      
      [ -f ~/.fzf.bash ] && source ~/.fzf.bash
      
      if command -v fzf-share >/dev/null; then
        source $(fzf-share)/key-bindings.bash
        source $(fzf-share)/completion.bash
      fi
    '';
    
    profileExtra = ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        exec hyprland
      fi
      
      export PATH=${config.home.homeDirectory}/.local/bin:$PATH
    '';
  };
  
  programs.starship.enable = true;
  
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };
  
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };
}
