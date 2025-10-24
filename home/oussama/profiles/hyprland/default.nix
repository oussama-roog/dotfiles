{ config, pkgs, ... }:

{
  imports = [
    ../../../modules/home-manager/bash.nix
    ../../../modules/home-manager/tmux.nix
    ../../../modules/home-manager/tmux-sessionizer.nix
  ];

  home.packages = with pkgs; [
    yazi
    ripgrep
    fd
    lazygit
  ];

  xdg.configFile = let
    dotfiles = "${config.home.homeDirectory}/dotfiles/.config";
    create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
    configs = {
      hypr = "hypr";
      nvim = "nvim";
      waybar = "waybar";
      rofi = "rofi";
      ghostty = "ghostty";
      yazi = "yazi";
      lazygit = "lazygit";
    };
  in
    builtins.mapAttrs (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    }) configs;
}
