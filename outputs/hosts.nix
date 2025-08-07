{ inputs, ... }:
let
  inherit (import ../lib { inherit inputs; }) mkSystem mkHome;
in
{
  flake = {
    nixosConfigurations = {
      desktop = mkSystem {
        hostName = "desktop";
        system = "x86_64-linux";
        username = "drakeb";
        format = "nixos";
        desktopEnvironment = "plasma";
        extraSystemModules = [{
          home-manager.extraSpecialArgs = {
            neorgWorkspace = "chalet";
            root = ./.;
          };
        }];
      };

      pocket = mkSystem {
        hostName = "pocket";
        system = "x86_64-linux";
        username = "drakeb";
        format = "nixos";
        desktopEnvironment = "plasma";
        extraSystemModules = [{
          home-manager.extraSpecialArgs = {
            neorgWorkspace = "chalet";
            root = ./.;
          };
        }];
      };
    };

    darwinConfigurations = {
      macbook = mkSystem {
        hostName = "macbook";
        system = "aarch64-darwin";
        username = "drakebott";
        format = "darwin";
        extraSystemModules = [{
          home-manager.extraSpecialArgs = {
            neorgWorkspace = "chalet";
            root = ./.;
          };
        }];
      };
    };

    homeConfigurations = {
      standalone = mkHome {
        hostName = "standalone";
        system = "aarch64-darwin";
        username = "drakebott";
        format = "home-manager";
      };
    };
  };
}
