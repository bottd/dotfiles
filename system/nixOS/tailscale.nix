{ username, ... }:

{
  services.tailscale.extraSetFlags = [ "--operator=${username}" ];
}
