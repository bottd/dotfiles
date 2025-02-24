{
  pkgs,
  nixpkgs,
  ...
}: {
  home.packages = with pkgs; [
    (discord.override {
      # withOpenASAR = true;
      # Vencord produces an unopenable discord client on mac for me
      # withVencord = true;
    })

    spotify
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "spotify"
      "discord"
    ];
}
