# quote shares its physical hardware with the desktop host;
# the auto-generated config lives there and updates via nixos-generate-config.
{ ... }:
{
  imports = [ ../desktop/hardware-configuration.nix ];
}
