{ features, lib, ... }:
{
  imports = [
    ./theme.nix
  ] ++ lib.optionals features.gui [
    ./desktop.nix
    ./mpv
  ] ++ lib.optionals features.gaming [
    ./games
  ] ++ lib.optionals (features.desktopEnvironment == "sway") [
    ./sway
  ] ++ lib.optionals (features.desktopEnvironment == "niri") [
    ./niri
  ];
}
