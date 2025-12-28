{ desktopEnvironment, ... }:
{
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./catppuccin.nix
    ./cli.nix
    ./gaming.nix
    ./graphics.nix
    ./jellyfin.nix
    ./keyring.nix
    ./mullvad.nix
    ./printing.nix
  ] ++ (
    if desktopEnvironment == "niri"
    then [ ./niri ]
    else if desktopEnvironment == "plasma"
    then [ ./plasma ]
    else [ ]
  );
}
