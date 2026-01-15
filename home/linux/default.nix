{ desktopEnvironment ? null, hostName, includeGui ? true, includeGaming ? false, lib, ... }:
{
  imports = lib.optionals includeGui [
    ./desktop.nix
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
