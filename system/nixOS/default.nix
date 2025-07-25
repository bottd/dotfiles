{ desktopEnvironment, ... }:
{
  imports = [
    ./audio.nix
    ./catppuccin.nix
    ./cli.nix
    ./gaming.nix
    ./graphics.nix
    ./jellyfin.nix
    ./keyring.nix
    ./mullvad.nix
    ./printing.nix
    ./torrent.nix
  ] ++ (
    if desktopEnvironment == "hyprland"
    then [ ./hyprland ]
    else [ ./plasma ]
  );
}
