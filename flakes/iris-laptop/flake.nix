{
  description = "Drake - Iris Laptop (work)";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    mac-app-util.url = "github:hraban/mac-app-util";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, home-manager, mac-app-util, nixos-hardware, nixpkgs, ... }: {
    packages.aarch64-darwin = {
      default = home-manager.defaultPackage.aarch64-darwin;
      homeConfigurations = {
        DBott = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {system = "aarch64-darwin";};

          extraSpecialArgs = {
            username = "DBott";
            root = ../../.;
            neorgWorkspace = "notes";
          };

          modules = [
            mac-app-util.homeManagerModules.default
            ../../util/default.nix
            ../../home.nix 
            ../../packages/darwin/default.nix
            ../../packages/common/default.nix
          ];
        };
      };
    };
  };
}
