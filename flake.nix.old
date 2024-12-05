# Ideas:
## Add darwinConfigurations and nixOSConfigurations alongside homeConfigurations
## https://github.com/MatthiasBenaets/nix-config/blob/master/darwin/default.nix
{
  description = "Drake - Nix Common";
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

    nixvim = {
        url = "github:nix-community/nixvim";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, home-manager, mac-app-util, nixos-hardware, nixpkgs, nixvim, ... }: {
    packages.x86_64-linux = {
      default = home-manager.defaultPackage.x86_64-linux;
      homeConfigurations = {
        desktop = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;

          extraSpecialArgs = {
            username = "drake";
            root = ./.;
          };

          modules = [
            ./home.nix 
            ./hosts/linux/default.nix
          ];
        };
      };
    };

    packages.aarch64-darwin = {
      default = home-manager.defaultPackage.aarch64-darwin;
      homeConfigurations = {
        drakebott = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {system = "aarch64-darwin";};

          extraSpecialArgs = {
            username = "drakebott";
            root = ./.;
          };

          modules = [
            mac-app-util.homeManagerModules.default
            ./home.nix 
            ./hosts/personal/macbook.nix
          ];
        };

        work = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {system = "aarch64-darwin";};

          extraSpecialArgs = {
            username = "DBott";
            root = ./.;
          };

          modules = [
            mac-app-util.homeManagerModules.default
            ./home.nix 
            ./hosts/work-laptop.nix
          ];
        };
      };
    };
  };
}
