{ pkgs
, ...
}: {
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
      gamescopeSession.enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
  };
  environment.systemPackages = with pkgs; [
    mangohud
    moonlight
  ];

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };
}
