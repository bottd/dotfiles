{ pkgs, ... }:

{
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  # Enable the Mullvad daemon
  systemd.services.mullvad-daemon.wantedBy = [ "multi-user.target" ];

  # `waybar-mullvad login` (scripts/waybar/mullvad.clj) logs in with the
  # account number from Bitwarden.
}
