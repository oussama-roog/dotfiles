{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.configurationLimit = 5;
  };

  time.timeZone = "Africa/Algiers";

  networking = {
    hostName = "dell-pc";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.oussama = {
    isNormalUser = true;
    description = "oussama";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    audio.enable = true;
  };

  services.displayManager.ly.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.niri.enable = true;

  environment.variables.EDITOR = "nvim";

  virtualisation.docker.enable = true;

  # System-level essential packages only
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    tree

    unzip
    unrar
    zip
    ffmpeg
    jq
    parted
  ];

  system.stateVersion = "25.05";
}
