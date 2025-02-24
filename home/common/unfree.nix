{
  lib,
  nixpkgs,
  pkgs,
  ...
}: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "spotify"
    ];

  home.packages = with pkgs; [
    (discord.override {
      # withOpenASAR = true;
      # Vencord produces an unopenable discord client on mac for me
      # withVencord = true;
    })

    spotify
  ];
}
