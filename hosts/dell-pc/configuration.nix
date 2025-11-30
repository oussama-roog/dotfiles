{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/base.nix
    ../../modules/system/desktop.nix
    ../../modules/system/docker.nix
    ../../modules/system/printing.nix
  ];

  # Host-specific settings
  networking.hostName = "dell-pc";

  # User configuration
  users.users.oussama = {
    isNormalUser = true;
    description = "oussama";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };
}
