{ config, pkgs, ... }:

{
  # Basic home-manager settings
  home.stateVersion = "25.11";

  # Enable dark mode preference
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # User fonts
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    icomoon-feather
  ];

  # Media player control daemon
  services.playerctld.enable = true;

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "oussamaroog@gmail.com";
        name = "oussama-roog";
      };
      init.defaultBranch = "main";
    };
  };
}
