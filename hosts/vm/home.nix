{ config, pkgs, system, inputs, unstable, ... }:

{
  imports = [
    ../../modules/home/base.nix
    ../../modules/home/bash.nix
    ../../modules/home/tmux.nix
    ../../modules/home/packages.nix
    ../../modules/home/dev-tools.nix
    ../../modules/home/xdg.nix
    ../../modules/home/desktop-environment.nix
  ];

  # User-specific settings
  home.username = "oussama";
  home.homeDirectory = "/home/oussama";
}
