{ config, pkgs, ... }:

{
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

  services.displayManager.sddm.enable = true;

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

  environment.variables = {
    EDITOR = "nvim";
  };

  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

  environment.systemPackages = with pkgs; [
    kitty
    ghostty
    waybar
    hyprpaper
    rofi-wayland
    rofi-calc
    dunst
    wl-clipboard
    cliphist
    
    neovim
    
    btop
    
    bibata-cursors
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    icomoon-feather
  ];
}
