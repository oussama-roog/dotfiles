{ config, pkgs, system, inputs, unstable, ... }:

let
  configs = {
    hypr = "hypr";
    nvim = "nvim";
    waybar = "waybar";
    rofi = "rofi";
    ghostty = "ghostty";
    yazi = "yazi";
    lazygit = "lazygit";
    dunst = "dunst";
  };
in
{
  imports = [
    ./bash.nix
    ./tmux.nix
    ./packages.nix
    ./dev-tools.nix
  ];

  home.username = "oussama";
  home.homeDirectory = "/home/oussama";
  home.stateVersion = "25.05";

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  services.playerctld.enable = true;

  programs.git = {
    enable = true;
    userEmail = "oussamaroog@gmail.com";
    userName = "oussama-roog";
    extraConfig = {
      init.defaultBranch = "main";
      # safe = { directory = []; };
    };
  };

  xdg.configFile = let
    dotfiles = "${config.home.homeDirectory}/dotfiles/.config";
    create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  in
    builtins.mapAttrs (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    }) configs;
}
