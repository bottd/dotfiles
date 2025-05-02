{pkgs, ...}: {
  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
    };
  };

  steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };
}
