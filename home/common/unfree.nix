{
  lib,
  pkgs,
  nixpkgs,
  ...
}: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "spotify"
    ];

  # nixpkgs.config.allowUnfreePredicate = pkg:
  #   builtins.elem (lib.getName pkg) (map lib.getName [
  #     pkgs.discord
  #     pkgs.spotify
  #   ]);

  home.packages = with pkgs; [
    (discord.override {
      # withOpenASAR = true;
      # Vencord produces an unopenable discord client on mac for me
      # withVencord = true;
    })

    spotify
  ];
}
