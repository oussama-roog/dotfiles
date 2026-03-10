{ ... }:

{
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

  # Display manager
  services.displayManager.ly.enable = true;

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # Window managers
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.niri.enable = true;

  # i3 (X11)
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
}
