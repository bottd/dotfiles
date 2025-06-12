{ pkgs, ... }:

{
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  # Enable the Mullvad daemon
  systemd.services.mullvad-daemon.wantedBy = [ "multi-user.target" ];
}
