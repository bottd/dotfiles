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
  # mango reuses the niri module's shell (Quickshell, mako, swaylock, wallpaper)
  # and adds its own compositor config on top.
  ++
    lib.optionals
      (lib.elem features.desktopEnvironment [
        "niri"
        "mango"
      ])
      [
        ./niri
      ]
  ++ lib.optionals (features.desktopEnvironment == "mango") [
    ./mango.nix
  ];

  # Not behind desktopApps: every host sets default applications (the browser
  # at least), and without `enable` they are silently never written.
  xdg = {
    mimeApps.enable = true;
    configFile."mimeapps.list".force = true;
  };
}
