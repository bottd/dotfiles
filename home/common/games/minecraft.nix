{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    (prismlauncher.override {
      jdks = [
        temurin-bin-25
        temurin-bin-21
        temurin-bin-17
      ]
      ++ lib.optional stdenv.isLinux temurin-bin-8;
    })
  ];

  programs.java = {
    enable = true;
    package = pkgs.temurin-bin-21;
  };
}
