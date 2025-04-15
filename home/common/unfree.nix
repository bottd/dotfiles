{
  lib,
  nixpkgs,
  pkgs,
  ...
}: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "spotify"
      "code-cursor"
    ];

  home.packages = with pkgs; [
    spotify
    code-cursor
  ];
}
