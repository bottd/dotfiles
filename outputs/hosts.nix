{ inputs, ... }:
let
  inherit (import ../lib { inherit inputs; }) mkSystem mkHome;

  chaletArgs = [{
    home-manager.extraSpecialArgs = {
      neorgWorkspace = "chalet";
      root = ./.;
    };
  }];

  baseSystem = {
    system = "x86_64-linux";
    username = "drakeb";
    format = "nixos";
    desktopEnvironment = "plasma";
    extraSystemModules = chaletArgs;
  };
in
{
  flake = {
    nixosConfigurations = {
      desktop = mkSystem (baseSystem // {
        hostName = "desktop";
      });

      eink = mkSystem {
        hostName = "eink";
        system = "x86_64-linux";
        username = "drakeb";
        format = "nixos";
        desktopEnvironment = "sway";
        extraSystemModules = chaletArgs;
      };

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
        extraSystemModules = chaletArgs;
      };
    };

    darwinConfigurations = {
      macbook = mkSystem {
        hostName = "macbook";
        system = "aarch64-darwin";
        username = "drakebott";
        format = "darwin";
        desktopEnvironment = "macos";
        extraSystemModules = chaletArgs;
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
