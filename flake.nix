{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, zen-browser, ... } @ inputs:
    let
      system = "x86_64-linux";
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      # Helper function to create a host configuration
      mkHost = hostname: hostConfig: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs unstable hostConfig; };
        modules = [
          ./hosts/${hostname}/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.oussama = import ./hosts/${hostname}/home.nix;
              backupFileExtension = "backup";
              extraSpecialArgs = {
                inherit inputs unstable system hostConfig;
              };
            };
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        dell-pc = mkHost "dell-pc" {
          hostName = "dell-pc";
          isVM = false;
          hasDataPartition = true;
        };
        vm = mkHost "vm" {
          hostName = "vm";
          isVM = true;
          hasDataPartition = false;
        };
      };
    };
}
