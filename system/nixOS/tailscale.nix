{ username, features, lib, pkgs, ... }:

{
  services.tailscale.extraSetFlags = [ "--operator=${username}" ];

  environment.systemPackages = lib.optionals features.gui [ pkgs.trayscale ];
}
