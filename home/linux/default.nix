{ features, lib, ... }:
{
  imports = [
    ./theme.nix
  ]
  ++ lib.optionals features.desktopApps [
    ./desktop.nix
    ./equibop
    ./mpv
    ./spicetify.nix
    ./tailscale.nix
    ./tresorit.nix
  ]
  ++ lib.optionals features.gaming [
    ./games
  ]
  ++ lib.optionals (features.desktopEnvironment == "niri") [
    ./niri
  ];

  # Not behind desktopApps: every host sets default applications (the browser
  # at least), and without `enable` they are silently never written.
  xdg = {
    mimeApps.enable = true;
    configFile."mimeapps.list".force = true;
  };
}
