{
  description = "Drake - Desktop";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    }
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      hostname = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.drakeb = import ../../home.nix;

              # Optionally, use home-manager.extraSpecialArgs to pass
              # arguments to home.nix
              extraSpecialArgs = {
                username = "drakeb";
                root = ../../.;
                neorgWorkspace = "chalet";
              };
            }
          }
          ../../util/default.nix
          ../../home.nix
          ../../packages/common/default.nix
        ];
      };
    };
  };
}
