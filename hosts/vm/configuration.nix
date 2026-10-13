{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/base.nix
    ../../modules/system/vm.nix
    ../../modules/system/docker.nix
  ];

  # Host-specific settings
  networking.hostName = "vm";

  security.pki.certificateFiles = [
    /etc/nixos/certs/FG1.cer
    /etc/nixos/certs/FG2.cer
    /etc/nixos/certs/FG3.cer
    /etc/nixos/certs/kaspersky.cer
  ];

  environment.sessionVariables = {
    NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
  };

  # User configuration
  users.users.oussama = {
    isNormalUser = true;
    description = "oussama";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  # VMware shared folder mount (maps to Windows partition/folder)
  # In VMware: VM > Settings > Options > Shared Folders > Add "share" pointing to your Windows folder/partition
  fileSystems."/home/oussama/share" = {
    device = ".host:/share";
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    options = [
      "umask=022"
      "uid=1000"
      "gid=100"
      "allow_other"
      "auto_unmount"
      "defaults"
      "_netdev"
      "x-systemd.automount"
    ];
  };
}
