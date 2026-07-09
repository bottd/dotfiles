{ config, username, features, ... }:
# The autologin path (desktop, eink). Non-autologin hosts get sddm.nix instead.
# Only imported for niri hosts; fail loud if a new DE reaches here without its
# own session command.
assert features.desktopEnvironment == "niri";
{
  services.greetd.enable = true;

  services.greetd.settings.default_session = {
    command = "${config.programs.niri.package}/bin/niri-session";
    user = username;
  };
}
