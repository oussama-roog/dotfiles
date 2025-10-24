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

  # Configure keymap in X11
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
    tmux
    go 
    btop 
    cmake
    gnumake 
    libgcc
    gcc
    rofi-calc
    dunst
    unzip
    unrar 
    fzf 
    wl-clipboard
    zip 
    zoxide
    yazi
    cliphist
    ripgrep
    fd
    rustup
    lua 
    gdb 
    lldb
    python311
    lua54Packages.luarocks
    bibata-cursors
  ];

  fonts.packages = with pkgs; [
	nerd-fonts.jetbrains-mono
    icomoon-feather
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  system.stateVersion = "25.05";
}
