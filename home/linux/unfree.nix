{
  lib,
  nixpkgs,
  pkgs,
  ...
}: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "android-studio"
      "discord"
      "steam"
    ];

  home.packages = with pkgs; [
    android-studio
    (discord.override {
      # withOpenASAR = true;
      # Vencord produces an unopenable discord client on mac for me
      # withVencord = true;
    })

    steam
  ];
}
