{ config, pkgs, lib, hostConfig, ... }:

{
  programs.bash = {
    enable = true;

    shellAliases = {
      v = "nvim";
      y = "yazi";
      ta = "tmux attach-session -t oussama || tmux new-session -s oussama";
      tk = "pkill tmux";
      lg = "lazygit";
      op = "tmux-sessionizer";
      btw = "echo nixos and neovim btw";

      # SQL clients
      sql = "usql";
      pgsql = "pgcli";
      dbl = "dblab";

      # NixOS management (uses hostConfig for correct host name)
      nxs = "sudo nixos-rebuild switch --flake ~/dotfiles#${hostConfig.hostName}";
      nxu = "sudo nix flake update --flake ~/dotfiles";
      nxg = "sudo nix-collect-garbage -d";
      nxo = "sudo nix-store --optimise";
    }
    // lib.optionalAttrs hostConfig.hasDataPartition {
      data = "sudo mount -t ntfs3 -o uid=1000,gid=100,umask=022 /dev/nvme0n1p5 /home/oussama/data";
      udata = "sudo umount /home/oussama/data";
      data-clean = "sudo ntfsfix -d /dev/nvme0n1p5";
    }
    // lib.optionalAttrs hostConfig.isVM {
      share = "cd ~/share";
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
       export PATH=${config.home.homeDirectory}/.local/bin:$PATH
    '' + lib.optionalString hostConfig.isVM ''
      # Auto-start niri on TTY1 (VM: no display manager)
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        exec niri-session 2>/dev/null || exec niri
      fi
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
