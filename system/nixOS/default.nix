{ features, lib, ... }:
{
  imports = [
    ../common/nix.nix
    ./audio.nix
    ./bluetooth.nix
    ./cli.nix
    ./graphics.nix
    ./jellyfin.nix
    ./keyring.nix
    ./mullvad.nix
    ./printing.nix
    ./stylix.nix
  ] ++ lib.optionals features.gaming [
    ./gaming.nix
  ] ++ lib.optionals (features.desktopEnvironment == "niri") [
    ./greetd.nix
    ./niri
  ];
}
