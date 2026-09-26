{ inputs, ... }:
let
  inherit (import ../lib { inherit inputs; }) mkSystem;

  # The bare name is the light variant; share its evaluation.
  mkWithVariants = name: args:
    let
      withAppearance = appearance: mkSystem (args // { theme = (args.theme or { }) // { inherit appearance; }; });
      light = withAppearance "light";
    in
    {
      "${name}" = light;
      "${name}-dark" = withAppearance "dark";
      "${name}-light" = light;
    };

  baseSystem = {
    system = "x86_64-linux";
    username = "drakeb";
    format = "nixos";
    features.desktopEnvironment = "niri";
    theme.baseFontSize = 12;
  };
in
{
  flake = {
    nixosConfigurations =
      mkWithVariants "desktop"
        (baseSystem // {
          hostName = "desktop";
          autologin = true;
          features = baseSystem.features // { gaming = true; };
        })
      // mkWithVariants "eink" (baseSystem // {
        hostName = "eink";
        features = baseSystem.features // { gui = false; };
        theme = { baseFontSize = 20; scheme = "primer"; };
        autologin = true;
      })
      // mkWithVariants "pocket" (baseSystem // {
        hostName = "pocket";
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
        };
      };

    darwinConfigurations =
      mkWithVariants "macbook" {
        hostName = "macbook";
        system = "aarch64-darwin";
        username = "drakebott";
        format = "darwin";
        features = { desktopEnvironment = "macos"; gaming = true; };
        theme.baseFontSize = 12;
      };
  };
}
