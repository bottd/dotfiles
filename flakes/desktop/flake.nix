{
  description = "Drake - Desktop";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { 
    self, 
    nixpkgs,
    home-manager, 
    ... 
  } @ inputs: let 
    inherit (self) outputs;
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs outputs;
        };
        modules = [
          ./configuration.nix
        ];
      };
    };
    homeConfigurations = {
      "drakeb@nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          username = "drakeb";
          root = ../../.;
          neorgWorkspace = "chalet";
        };
        modules = [
          ../../util/default.nix
          ../../home.nix
          ../../packages/common/default.nix
          ../../packages/linux/default.nix
        ];
      };
    };
  };
}
