{ config
, lib
, ...
}: {

  flake.systemModules = {
    baseSystem = { pkgs, ... }: {
      nixpkgs.config.allowUnfree = true;
      nix = {
        settings = {
          experimental-features = [ "nix-command" "flakes" ];
          trusted-users = [ "root" "@wheel" ];

          substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
            "https://catppuccin.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
          ];
          max-jobs = "auto";
          cores = 0;
          keep-outputs = true;
          keep-derivations = true;
          sandbox = true;
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

      boot = {
        loader.systemd-boot.enable = lib.mkDefault true;
        loader.efi.canTouchEfiVariables = lib.mkDefault true;
        tmp.useTmpfs = lib.mkDefault true;
      };
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
