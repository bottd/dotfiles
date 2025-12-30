{ desktopEnvironment, includeGaming ? false, lib, ... }:
{
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./catppuccin.nix
    ./cli.nix
    ./graphics.nix
    ./jellyfin.nix
    ./keyring.nix
    ./mullvad.nix
    ./printing.nix
  ] ++ lib.optionals includeGaming [
    ./gaming.nix
  ] ++ (
    if desktopEnvironment == "niri"
    then [ ./niri ]
    else if desktopEnvironment == "plasma"
    then [ ./plasma ]
    else if desktopEnvironment == "sway"
    then [ ./sway ]
    else [ ]
  );
}
