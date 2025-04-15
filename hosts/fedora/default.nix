{inputs, ...}: let
  inherit (inputs) home-manager mac-app-util nixpkgs;
in
  home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    extraSpecialArgs = {
      username = "Mko";
      root = ../../.;
      inherit inputs;
    };
    modules = [
      mac-app-util.homeManagerModules.default
      ./configuration.nix
      ../../util/default.nix
      ../../home.nix
      ../../home/default.nix
    ];
  }
