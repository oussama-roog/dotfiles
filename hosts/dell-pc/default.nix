{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/nixos/core.nix
    ../../modules/nixos/desktop.nix
  ];

  networking.hostName = "dell-pc";

  users.users.oussama = {
    isNormalUser = true;
    description = "oussama";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  system.stateVersion = "25.05";
}
