{ pkgs, ... }:

{
  services.mullvad-vpn = {
    enable = true;
    # Default package is the CLI-only pkgs.mullvad; we want the GUI client.
    package = pkgs.mullvad-vpn;
  };

  # `waybar-mullvad login` (scripts/waybar/mullvad.clj) logs in with the
  # account number from Bitwarden.
}
