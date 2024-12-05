# Ideas:
## Add darwinConfigurations and nixOSConfigurations alongside homeConfigurations
## https://github.com/MatthiasBenaets/nix-config/blob/master/darwin/default.nix
{
  description = "Drake - Personal MacBook";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    mac-app-util.url = "github:hraban/mac-app-util";

    # darwin = {
    #   url = "github:LnL7/nix-darwin";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, home-manager, mac-app-util, nixos-hardware, nixpkgs, ... }: {
    packages.aarch64-darwin = {
      default = home-manager.defaultPackage.aarch64-darwin;
      homeConfigurations = {
        drakebott = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {system = "aarch64-darwin";};

          extraSpecialArgs = {
            username = "drakebott";
            root = ../../.;
          };

          modules = [
            mac-app-util.homeManagerModules.default
            ../../home.nix 
            ../../hosts/personal/macbook.nix
          ];
        };
      };
    };
  };
}
