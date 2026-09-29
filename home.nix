{
  pkgs,
  username,
  host,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in
{
  home = {
    inherit username;
    stateVersion = host.stateVersion.home;
    homeDirectory = if isLinux then "/home/${username}" else "/Users/${username}";
  };

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = isLinux;
  xdg.enable = true;
}
