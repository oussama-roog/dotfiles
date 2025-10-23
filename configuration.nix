{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dell-pc"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Africa/Algiers";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ar_DZ.UTF-8";
    LC_IDENTIFICATION = "ar_DZ.UTF-8";
    LC_MEASUREMENT = "ar_DZ.UTF-8";
    LC_MONETARY = "ar_DZ.UTF-8";
    LC_NAME = "ar_DZ.UTF-8";
    LC_NUMERIC = "ar_DZ.UTF-8";
    LC_PAPER = "ar_DZ.UTF-8";
    LC_TELEPHONE = "ar_DZ.UTF-8";
    LC_TIME = "ar_DZ.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.getty.autologinUser = "oussama";

  programs.hyprland = {
	enable = true;
	xwayland.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.oussama = {
    isNormalUser = true;
    description = "oussama";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };
 
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
	vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
	wget
	kitty
	waybar
	git
	hyprpaper
	ghostty
	rofi-wayland
	neovim
  ];

  fonts.packages = with pkgs; [
	nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  system.stateVersion = "25.05";

}
