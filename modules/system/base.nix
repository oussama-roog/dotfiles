{ pkgs, ... }:

{
  # Boot configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.configurationLimit = 5;
  };

  # Basic system settings
  time.timeZone = "Africa/Algiers";
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Networking
  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
  };

  # Essential system packages
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
    system-config-printer
  ];

  environment.variables.EDITOR = "nvim";

  # Battery / power state over D-Bus (quickshell's battery reads it)
  services.upower.enable = true;

  system.stateVersion = "26.05";
}
