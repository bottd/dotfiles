{
  username,
  features,
  lib,
  pkgs,
  ...
}:

{
  services.tailscale.extraSetFlags = [ "--operator=${username}" ];

  environment.systemPackages = lib.optionals features.desktopApps [ pkgs.trayscale ];
}
