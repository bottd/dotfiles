{ pkgs, neorgWorkspace, ... }:
{
  services.syncthing = {
    enable = true;
    tray.enable = pkgs.stdenv.hostPlatform.isLinux;
    settings = {
      folders = {
        "${neorgWorkspace}" = {
          path = "~/${neorgWorkspace}";
          devices = [ "cellar-pi" ];
          versioning = {
            type = "simple";
            params.keep = "10";
          };
        };
      };
      options = {
        urAccepted = -1;
        relaysEnabled = true;
        localAnnounceEnabled = true;
      };
    };
  };
}
