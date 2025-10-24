{
  description = "NixOS configuration with multi-host and multi-user support";

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
    
    mkHost = hostname: username:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs unstable; };
        modules = [
          ./hosts/${hostname}
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import ./home/${username};
              backupFileExtension = "backup";
              extraSpecialArgs = { 
                inherit inputs unstable system;
              };
            };
          }
        ];
      };
  in
  {
    nixosConfigurations = {
      dell-pc = mkHost "dell-pc" "oussama";
    };
  };
}
