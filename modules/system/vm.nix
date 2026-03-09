{ pkgs, ... }:

{
  # Keyboard layout
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Audio with pipewire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    audio.enable = true;
  };

  # VMware guest support (clipboard, drag-and-drop, resolution auto-resize)
  virtualisation.vmware.guest.enable = true;

  # Niri window manager
  programs.niri.enable = true;

  # Auto-login on TTY1 (niri starts via bash profileExtra)
  services.getty.autologinUser = "oussama";
}
