{ desktopEnvironment, hostName, includeGui, includeGaming, lib, ... }:
{
  imports = [
    ./theme.nix
  ] ++ lib.optionals includeGui [
    ./desktop.nix
    ./mpv
  ] ++ lib.optionals includeGaming [
    ./games
  ] ++ lib.optionals (desktopEnvironment == "plasma") [
    ./plasma
  ] ++ lib.optionals (desktopEnvironment == "sway") [
    ./sway
  ] ++ lib.optionals (desktopEnvironment != null && desktopEnvironment != "sway") [
    ./${desktopEnvironment}/host/${hostName}.nix
  ];
}
