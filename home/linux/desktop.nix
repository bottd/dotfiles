{ inputs
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    (discord.override {
      # withOpenASAR = true;
      # Vencord produces an unopenable discord client on mac for me
      # withVencord = true;
    })
    flashprint
    geary
    thunderbird
    nyxt
    obs-studio
    vlc
    inputs.zen-browser.packages.${pkgs.system}.default
  ];
}
