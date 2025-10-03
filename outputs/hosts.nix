{ inputs, ... }:
let
  inherit (import ../lib { inherit inputs; }) mkSystem mkHome;

  baseSystem = {
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
in
{
  flake = {
    nixosConfigurations = {
      desktop = mkSystem (baseSystem // {
        hostName = "desktop";
      });

      eink = mkSystem (baseSystem // {
        hostName = "eink";
      });

      pocket = mkSystem (baseSystem // {
        hostName = "pocket";
      });

      android = mkSystem {
        hostName = "android";
        system = "aarch64-linux";
        username = "droid";
        format = "nixos";
        enableAVF = true;
        extraHomeModules = [ ../hosts/android/home.nix ];
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
