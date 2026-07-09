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
        # MonoLisa itself is a commercial font installed outside Nix, so `name`
        # resolves against the system fontconfig. `package` only feeds
        # fonts.packages, so use it to ship the Nerd Font glyphs — otherwise
        # waybar's icons fall back to DejaVu and render as tofu.
        package = pkgs.nerd-fonts.symbols-only;
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
