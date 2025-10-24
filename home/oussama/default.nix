{ config, pkgs, system, inputs, unstable, ... }:

{
  imports = [
    ./profiles/hyprland
  ];

  home.username = "oussama";
  home.homeDirectory = "/home/oussama";
  home.stateVersion = "25.05";

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  programs.git = {
    enable = true;
    userEmail = "oussamaroog@gmail.com";
    userName = "oussama-roog";
    extraConfig = {
      init.defaultBranch = "main";
      safe = {
        directory = [
          "/mnt/data/Notes"
          "/mnt/data/Projects/codecrafters-http-server-c"
          "/mnt/data/Projects/simple-http-server"
          "/mnt/data/Projects/whathiq/wathiq-app"
          "/mnt/data/Projects/go-tuto/femProject"
          "/mnt/data/Projects/zaki/dotfiles"
          "/mnt/data/Projects/zaki/dotfiles-zaki"
          "/mnt/data/Projects/Pnet"
        ];
      };
    };
  };

  home.packages = with pkgs; [
    nodejs
    unstable.opencode
    inputs.zen-browser.packages."${system}".beta
    
    go
    cmake
    gnumake
    libgcc
    gcc
    rustup
    lua
    gdb
    lldb
    python311
    lua54Packages.luarocks
  ];
}
