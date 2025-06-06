{ config
, lib
, ...
}: {
  imports = [ ];

  flake.flakeModules = {
    commonHome = { pkgs, username, ... }: {
      imports = [ ];

      home.username = username;

      home.stateVersion = "24.11";
      programs.home-manager.enable = true;

      nix = {
        package = lib.mkForce pkgs.nix;
        settings.experimental-features = [ "nix-command" "flakes" ];
      };

      xdg.enable = true;
    };

    darwinHome = { username, ... }: {
      imports = [ config.flake.flakeModules.commonHome ];

      home.homeDirectory = "/Users/${username}";
      fonts.fontconfig.enable = false;
    };
  };
}
