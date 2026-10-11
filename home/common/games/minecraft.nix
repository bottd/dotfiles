{ lib, pkgs, ... }:
let
  prismlauncher = pkgs.prismlauncher.override {
    jdks =
      with pkgs;
      [
        temurin-bin-25
        temurin-bin-21
        temurin-bin-17
      ]
      ++ lib.optional stdenv.isLinux temurin-bin-8;
  };

  prismlauncher' =
    if pkgs.stdenv.isDarwin then
      prismlauncher.overrideAttrs (old: {
        dontWrapQtApps = true;
        buildCommand = old.buildCommand + ''
          exe=$out/Applications/PrismLauncher.app/Contents/MacOS/prismlauncher
          target=$(readlink -e "$exe")
          rm "$exe"
          makeQtWrapper "$target" "$exe"
        '';
      })
    else
      prismlauncher;
in
{
  home.packages = [ prismlauncher' ];

  programs.java = {
    enable = true;
    package = pkgs.temurin-bin-21;
  };
}
