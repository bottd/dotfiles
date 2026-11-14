{
  config,
  username,
  features,
  ...
}:
# The autologin path (desktop, eink). Non-autologin hosts get sddm.nix instead.
{
  services.greetd.enable = true;

  services.greetd.settings.default_session = {
    command =
      if features.desktopEnvironment == "mango" then
        # From system/nixOS/mango.nix.
        "/run/current-system/sw/bin/mango-session"
      else
        "${config.programs.niri.package}/bin/niri-session";
    user = username;
  };
}
