{
  desktop = {
    system = "x86_64-linux";
    format = "nixos";
    username = "drakeb";
    autologin = true;
    features = {
      desktopEnvironment = "niri";
      gaming = true;
    };
    stateVersion = {
      system = "25.05";
      home = "26.05";
    };
  };
  eink = {
    system = "x86_64-linux";
    format = "nixos";
    username = "drakeb";
    autologin = true;
    # e-ink, no dark mode
    appearances = [ "light" ];
    features = {
      desktopEnvironment = "niri";
      desktopApps = false;
      animations = false;
    };
    theme = {
      baseFontSize = 20;
      scheme = "primer";
    };
    stateVersion = {
      system = "25.05";
      home = "26.05";
    };
  };
  pocket = {
    system = "x86_64-linux";
    format = "nixos";
    username = "drakeb";
    features.desktopEnvironment = "niri";
    nix = {
      maxJobs = 2;
      cores = 2;
    };
    stateVersion = {
      system = "25.05";
      home = "26.05";
    };
  };
  macbook = {
    system = "aarch64-darwin";
    format = "darwin";
    username = "drakebott";
    features = {
      desktopEnvironment = "macos";
      gaming = true;
    };
    stateVersion = {
      system = 6;
      home = "26.05";
    };
  };
}
