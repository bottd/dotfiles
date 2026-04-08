{ inputs, ... }:
let
  inherit (import ../lib { inherit inputs; }) mkSystem mkHome;

  chaletArgs = [{
    home-manager.extraSpecialArgs = {
      root = ./.;
    };
  }];

  baseSystem = {
    system = "x86_64-linux";
    username = "drakeb";
    format = "nixos";
    features.desktopEnvironment = "plasma";
    features.gaming = true;
    theme.baseFontSize = 16;
    extraSystemModules = chaletArgs;
  };
in
{
  flake = {
    nixosConfigurations = {
      desktop = mkSystem (baseSystem // {
        hostName = "desktop";
        autologin = true;
      });

      eink = mkSystem {
        hostName = "eink";
        system = "x86_64-linux";
        username = "drakeb";
        format = "nixos";
        features = { desktopEnvironment = "sway"; gui = false; };
        theme = { scheme = "eink"; appearance = "light"; baseFontSize = 20; };
        autologin = true;
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
        features.gui = false;
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
        features.desktopEnvironment = "macos";
        theme.baseFontSize = 16;
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
