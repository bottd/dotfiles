{ features, lib, ... }:
{
  imports = [
    ./theme.nix
  ] ++ lib.optionals features.gui [
    ./desktop.nix
    ./equibop
    ./mpv
  ] ++ lib.optionals features.gaming [
    ./games
  ] ++ lib.optionals (features.desktopEnvironment == "niri") [
    ./niri
    ./spicetify.nix
  ];
}
