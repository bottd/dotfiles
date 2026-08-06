{ hostName, lib, ... }:
{
  # Applies to every nixosConfiguration, including the AVF hosts that skip
  # ../nixOS — mkSystem imports this on the `nixos` format.
  networking.hostName = lib.mkDefault hostName;

  security.sudo-rs = {
    enable = true;
    wheelNeedsPassword = true;
  };
}
