{ features, lib, ... }:
{
  imports = [
    ./theme.nix
  ] ++ lib.optionals features.gui [
    ./desktop.nix
    ./equibop
    ./mpv
    ./tailscale.nix
  ] ++ lib.optionals features.gaming [
    ./games
  ] ++ lib.optionals (features.desktopEnvironment == "niri") [
    ./niri
    ./spicetify.nix
  ];
}
