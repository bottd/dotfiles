{ theme, pkgs, ... }:
let
  inherit (import ../../lib/stylixScheme.nix { inherit pkgs; inherit (theme) appearance scheme; }) base16Scheme polarity;
in
{
  stylix = {
    enable = true;
    inherit base16Scheme polarity;
    image = null;

    fonts = {
      monospace = {
        name = "MonoLisa Nerd Font";
        # MonoLisa itself is a commercial font installed outside Nix, so `name`
        # resolves against the system fontconfig. `package` only feeds
        # fonts.packages, so on Linux use it to ship the Nerd Font glyphs —
        # otherwise waybar's icons fall back to DejaVu and render as tofu.
        # (On darwin the glyphs are installed outside Nix too, hence the no-op.)
        package = if pkgs.stdenv.isDarwin then pkgs.emptyDirectory else pkgs.nerd-fonts.symbols-only;
      };
      sizes.terminal = theme.baseFontSize;
    };
  };
}
