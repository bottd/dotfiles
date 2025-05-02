{pkgs, ...}: {
  programs = {
    gamemode = {
      enable = true;
    };
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
  };
  environment.systemPackages = with pkgs; [
    mangohud
  ];
}
