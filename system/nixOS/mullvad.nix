{ pkgs, ... }:

{
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  # Enable the Mullvad daemon
  systemd.services.mullvad-daemon.wantedBy = [ "multi-user.target" ];

  # `mullvad-ctl login` (scripts/mullvad-ctl.clj) logs in with the account
  # number from Bitwarden.
}
