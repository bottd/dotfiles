{ colorScheme, stylixTheme, baseFontSize, pkgs, ... }:
let
  inherit (import ../../lib/stylixScheme.nix { inherit pkgs colorScheme stylixTheme; }) scheme polarity;
in
{
  stylix = {
    enable = true;
    base16Scheme = scheme;
    inherit polarity;
    autoEnable = true;
    image = null;

    fonts = {
      monospace = {
        name = "MonoLisa Nerd Font";
        # MonoLisa is a commercial font installed outside Nix
        package = pkgs.emptyDirectory;
      };
      sizes.terminal = baseFontSize;
    };

    targets.grub.enable = false;

    homeManagerIntegration = {
      autoImport = true;
      followSystem = true;
    };
  };
}
