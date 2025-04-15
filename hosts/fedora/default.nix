{inputs, ...}: let
  inherit (inputs) home-manager nixpkgs;
in
  home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    extraSpecialArgs = {
      username = "Mko";
      root = ../../.;
      inherit inputs;
    };
    modules = [
      ./configuration.nix
      ../../util/default.nix
      ../../home.nix
      ../../home/default.nix
    ];
  }
