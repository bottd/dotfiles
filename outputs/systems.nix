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

    nixosSystem = { ... }: {
      imports = [
        config.flake.systemModules.baseSystem
      ];

      boot.loader.systemd-boot.enable = lib.mkDefault true;
      boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
      networking.networkmanager.enable = lib.mkDefault true;
      time.timeZone = lib.mkDefault "America/Chicago";
      i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
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
