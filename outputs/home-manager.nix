{ config
, lib
, ...
}: {
  flake.flakeModules = {
    commonHome = { pkgs, username, ... }: {

      home.username = username;

      home.stateVersion = "25.05";
      programs.home-manager.enable = true;

      nix = {
        package = lib.mkForce pkgs.nix;
        settings.experimental-features = [ "nix-command" "flakes" ];
      };

      xdg.enable = true;
    };

    linuxHome = { username, ... }: {
      imports = [ config.flake.flakeModules.commonHome ];

      home.homeDirectory = "/home/${username}";
      fonts.fontconfig.enable = true;
    };

    darwinHome = { username, ... }: {
      imports = [ config.flake.flakeModules.commonHome ];

      home.homeDirectory = "/Users/${username}";
      fonts.fontconfig.enable = false;
    };
  };
}
