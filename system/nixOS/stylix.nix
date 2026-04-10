{ theme, pkgs, ... }:
let
  inherit (import ../../lib/stylixScheme.nix { inherit pkgs; inherit (theme) appearance scheme; }) base16Scheme polarity;
in
{
  stylix = {
    enable = true;
    inherit base16Scheme;
    inherit polarity;
    autoEnable = true;
    image = null;

    fonts = {
      monospace = {
        name = "MonoLisa Nerd Font";
        # MonoLisa is a commercial font installed outside Nix
        package = pkgs.emptyDirectory;
      };
      sizes.terminal = theme.baseFontSize;
    };

    targets.grub.enable = false;

    homeManagerIntegration = {
      autoImport = true;
      followSystem = true;
    };
  };
}
