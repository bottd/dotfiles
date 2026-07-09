{ config, username, ... }:
# The autologin path (desktop, eink). Non-autologin hosts get sddm.nix instead.
{
  services.greetd.enable = true;

  services.greetd.settings.default_session = {
    command = "${config.programs.niri.package}/bin/niri-session";
    user = username;
  };
}
