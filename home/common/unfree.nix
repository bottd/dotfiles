{
  lib,
  nixpkgs,
  pkgs,
  ...
}: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "spotify"
    ];

  home.packages = with pkgs; [
    spotify
  ];
}
