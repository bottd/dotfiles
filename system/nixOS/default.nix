{ features, lib, ... }:
{
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./cli.nix
    ./graphics.nix
    ./jellyfin.nix
    ./keyring.nix
    ./mullvad.nix
    ./printing.nix
    ./stylix.nix
  ] ++ lib.optionals (features.desktopEnvironment != null) [
    ./greetd.nix
  ] ++ lib.optionals features.gaming [
    ./gaming.nix
  ] ++ (
    if features.desktopEnvironment == "niri"
    then [ ./niri ]
    else if features.desktopEnvironment == "plasma"
    then [ ./plasma ]
    else if features.desktopEnvironment == "sway"
    then [ ./sway ]
    else [ ]
  );
}
