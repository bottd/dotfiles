{ config
, lib
, ...
}: {
  imports = [ ];

  flake.systemModules = {
    baseSystem = { ... }: {
      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        trusted-users = [ "root" "@wheel" ];
        auto-optimise-store = true;
      };
    };

    darwinSystem = { ... }: {
      imports = [
        config.flake.systemModules.baseSystem
      ];

      services.nix-daemon.enable = true;
      nix.configureBuildUsers = true;
      time.timeZone = lib.mkDefault "America/Chicago";
    };
  };
}
