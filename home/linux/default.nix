{ desktopEnvironment ? null, hostName, lib, ... }:
{
  imports = [
    ./desktop.nix
    ./darkman.nix
    ./gaming.nix
  ] ++ lib.optionals (desktopEnvironment == "hyprland") [
    ./hyprland
  ] ++ lib.optionals (desktopEnvironment == "plasma") [
    ./plasma
  ] ++ lib.optionals (desktopEnvironment != null) [
    ./${desktopEnvironment}/host/${hostName}.nix
  ];
}
