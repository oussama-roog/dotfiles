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

  # Window managers
  programs.niri.enable = true;

  # i3 (X11) — no 3D accelerator needed
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;

  # Touchpad settings for X11 (matching niri touchpad config)
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
    };
  };

  # Display manager
  services.displayManager.ly.enable = true;
}
