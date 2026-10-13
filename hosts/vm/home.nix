{ config, pkgs, system, inputs, unstable, ... }:

{
  imports = [
    ../../modules/home/base.nix
    ../../modules/home/bash.nix
    ../../modules/home/tmux.nix
    ../../modules/home/packages.nix
    ../../modules/home/taskwarrior.nix
    ../../modules/home/dev-tools.nix
    ../../modules/home/xdg.nix
    ../../modules/home/desktop-environment.nix
    ../../modules/home/claude.nix
    ../../modules/home/antigravity.nix
    ../../modules/home/vmware-clipboard.nix
  ];

  # User-specific settings
  home.username = "oussama";
  home.homeDirectory = "/home/oussama";

  home.sessionVariables = {
    NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
  };
}
