{ pkgs, ... }:

{
  # Enable CUPS printing service
  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint ];
  };

  # Enable Avahi for network printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
