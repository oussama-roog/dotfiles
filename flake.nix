{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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
  in
  {
    nixosConfigurations.dell-pc = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs unstable; };
      modules = [
        ./hosts/dell-pc/configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.oussama = import ./home/oussama/home.nix;
            backupFileExtension = "backup";
            extraSpecialArgs = { 
              inherit inputs unstable system;
            };
          };
        }
      ];
    };
  };
}
