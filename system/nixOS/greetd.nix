{ config, lib, username, features, autologin, ... }:
# Only imported for niri hosts (system/nixOS/default.nix); fail loud if a new
# DE ever reaches here without its own session command.
assert features.desktopEnvironment == "niri";
{
  services.greetd.enable = true;

  programs.regreet.enable = !autologin;

  services.greetd.settings.default_session = lib.mkIf autologin {
    command = "${config.programs.niri.package}/bin/niri-session";
    user = username;
  };
}
