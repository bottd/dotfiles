# Ideas:
## Add darwinConfigurations and nixOSConfigurations alongside homeConfigurations
## https://github.com/MatthiasBenaets/nix-config/blob/master/darwin/default.nix
{
  description = "Drake - Personal MacBook";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    mac-app-util.url = "github:hraban/mac-app-util";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    }
  };

  outputs = inputs@{ self, flake-parts, home-manager, mac-app-util, nixos-hardware, nixpkgs, ... }: {
    packages.aarch64-darwin = {
      default = home-manager.defaultPackage.aarch64-darwin;
      homeConfigurations = {
        drakebott = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {system = "aarch64-darwin";};

          extraSpecialArgs = {
            username = "drakebott";
            root = ../../.;
            neorgWorkspace = "chalet";
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
