{
  description = "Drake - Desktop";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./configuration.nix
        ];
      };
    };
    packages.x86_64-linux = {
      homeConfigurations = {
        drakeb = home-manager.nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.drakeb = import ../../home.nix;

            extraSpecialArgs = {
              username = "drakeb";
              root = ../../.;
              neorgWorkspace = "chalet";
            };
          };
          modules = [
            ../../util/default.nix
              ../../home.nix
              ../../packages/common/default.nix
          ];
        }
      }
    };
  };
}
