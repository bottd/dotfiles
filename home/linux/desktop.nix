{
  inputs,
  lib,
  nixpkgs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    (discord.override {
      # withOpenASAR = true;
      # Vencord produces an unopenable discord client on mac for me
      # withVencord = true;
    })
    geary
    nyxt
    obs-studio
    vlc
    inputs.zen-browser.packages."${system}".default
  ];
}
