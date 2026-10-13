{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/base.nix
    ../../modules/system/desktop.nix
    ../../modules/system/docker.nix
    ../../modules/system/printing.nix
  ];

  # Host-specific settings
  networking.hostName = "dell-pc";

  # Intel UHD 620 (i7-8550U): hardware video decode/encode through VA-API, so
  # browsers and players stop decoding video on the CPU.
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver ];
  };
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  # Always full performance, battery life doesn't matter: performance governor
  # (intel_pstate then sets EPP to performance too). No power-profiles-daemon,
  # it would put the CPU back on balanced.
  powerManagement.cpuFreqGovernor = "performance";

  # User configuration
  users.users.oussama = {
    isNormalUser = true;
    description = "oussama";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };
}
