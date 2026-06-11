# Shared nix daemon config for NixOS and darwin hosts.
{ lib, pkgs, ... }:
{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      max-jobs = "auto";
      cores = 0;
      keep-outputs = true;
      keep-derivations = true;
      download-buffer-size = 536870912; # 512 MiB
      http-connections = 128;
    };
    optimise.automatic = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    } // lib.optionalAttrs pkgs.stdenv.isLinux {
      # `dates` is the NixOS option; nix-darwin uses `interval` (default weekly)
      dates = "weekly";
    };
  };
}
