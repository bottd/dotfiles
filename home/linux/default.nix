{ features, hostName, lib, ... }:
{
  imports = [
    ./theme.nix
  ] ++ lib.optionals features.gui [
    ./desktop.nix
    ./mpv
  ] ++ lib.optionals features.gaming [
    ./games
  ] ++ lib.optionals (features.desktopEnvironment == "plasma") [
    ./plasma
  ] ++ lib.optionals (features.desktopEnvironment == "sway") [
    ./sway
  ] ++ lib.optionals (features.desktopEnvironment != null && features.desktopEnvironment != "sway") [
    ./${features.desktopEnvironment}/host/${hostName}.nix
  ];
}
