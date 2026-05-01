{ inputs, ... }:
let
  inherit (import ../lib { inherit inputs; }) mkSystem mkHome;

  chaletArgs = [{
    home-manager.extraSpecialArgs = {
      root = ./.;
    };
  }];

  mkWithVariants = name: args: {
    "${name}" = mkSystem args;
    "${name}-dark" = mkSystem (args // { theme = (args.theme or { }) // { appearance = "dark"; }; });
    "${name}-light" = mkSystem (args // { theme = (args.theme or { }) // { appearance = "light"; }; });
  };

  baseSystem = {
    system = "x86_64-linux";
    username = "drakeb";
    format = "nixos";
    features.desktopEnvironment = "plasma";
    features.gaming = true;
    theme.baseFontSize = 12;
    extraSystemModules = chaletArgs;
  };
in
{
  flake = {
    nixosConfigurations =
      mkWithVariants "desktop"
        (baseSystem // {
          hostName = "desktop";
          autologin = true;
        })
      // mkWithVariants "eink" {
        hostName = "eink";
        system = "x86_64-linux";
        username = "drakeb";
        format = "nixos";
        features = { desktopEnvironment = "sway"; gui = false; };
        theme = { appearance = "light"; baseFontSize = 20; scheme = "papercolor-light"; };
        autologin = true;
        extraSystemModules = chaletArgs;
      }
      // mkWithVariants "pocket" (baseSystem // {
        hostName = "pocket";
        theme = (baseSystem.theme or { }) // { appearance = "light"; };
      })
      // {
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

    darwinConfigurations =
      mkWithVariants "macbook" {
        hostName = "macbook";
        system = "aarch64-darwin";
        username = "drakebott";
        format = "darwin";
        features.desktopEnvironment = "macos";
        theme = { appearance = "light"; baseFontSize = 12; };
        extraSystemModules = chaletArgs;
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
