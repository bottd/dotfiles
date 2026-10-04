{ hostName, lib, ... }:
{
  # Applies to every nixosConfiguration — mkSystem imports this on the `nixos` format.
  imports = [ ./tailscale.nix ];

  networking.hostName = lib.mkDefault hostName;

  security.sudo-rs = {
    enable = true;
    wheelNeedsPassword = true;
  };
}
