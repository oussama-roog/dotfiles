{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  time.timeZone = "Africa/Algiers";

  networking = {
    hostName = "dell-pc";
    networkmanager.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.oussama = {
    isNormalUser = true;
    description = "oussama";
    extraGroups = [ "networkmanager" "wheel" ];
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

  programs.firefox.enable = true;

  environment.variables.EDITOR = "nvim";

  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    
    unzip
    unrar
    zip
    
    waybar
    swww
    hyprlock
    rofi-wayland
    libqalculate
    dunst
    wl-clipboard
    cliphist
    pulseaudio
    wireplumber
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    icomoon-feather
  ];

  system.stateVersion = "25.05";
}
