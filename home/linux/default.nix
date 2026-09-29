{ features, lib, ... }:
{
  imports = [
    ./theme.nix
  ]
  ++ lib.optionals features.desktopApps [
    ./desktop.nix
    ./equibop
    ./mpv
    ./obs.nix
    ./tailscale.nix
    ./tresorit.nix
  ]
  ++ lib.optionals features.gaming [
    ./games
  ]
  ++ lib.optionals (features.desktopEnvironment == "niri") [
    ./niri
    ./spicetify.nix
  ];
}
