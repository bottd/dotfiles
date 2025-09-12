{ config
, lib
, pkgs
, ...
}: {
  imports = [ ];

  flake.systemModules = {
    baseSystem = { ... }: {
      nixpkgs.config.allowUnfree = true;
      nix = {
        settings = {
          experimental-features = [ "nix-command" "flakes" ];
          trusted-users = [ "root" "@wheel" ];
        };
        optimise.automatic = true;
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 30d";
        };
      };

      time.timeZone = lib.mkDefault "America/Chicago";

      environment.systemPackages = with pkgs; [
        git
        curl
        wget
      ];

    };

    nixosSystem = { ... }: {
      system.stateVersion = "25.05";
      imports = [
        config.flake.systemModules.baseSystem
        ../system/common/linux
      ];

      boot.loader.systemd-boot.enable = lib.mkDefault true;
      boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
      networking.networkmanager.enable = lib.mkDefault true;
      i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
    };

    darwinSystem = { ... }: {
      system.stateVersion = 6;
      imports = [
        config.flake.systemModules.baseSystem
        ../system/common/darwin
      ];

      services.nix-daemon.enable = true;
      nix.configureBuildUsers = true;
    };
  };
}
