{ config, pkgs, ... }:

{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  time.timeZone = "Africa/Algiers";

  networking.networkmanager.enable = true;

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    unzip
    unrar
    zip
  ];
}
