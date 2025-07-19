{ desktopEnvironment, hostName, ... }:
{
  imports = [
    ./desktop.nix
    ./darkman.nix
    ./gaming.nix
  ] ++ (
    if desktopEnvironment == "hyprland"
    then [ ./hyprland ]
    else [ ./plasma ]
  ) ++ [
    ./${desktopEnvironment}/host/${hostName}.nix
  ];
}
