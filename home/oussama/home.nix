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
    "gtk-3.0" = "gtk-3.0";
    "gtk-4.0" = "gtk-4.0";
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

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "video/mp4" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/mpeg" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";
      "video/*" = "mpv.desktop";
      
      "image/png" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/jpg" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "image/bmp" = "imv.desktop";
      "image/*" = "imv.desktop";
    };
  };

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
