{ inputs, ... }:
let
  inherit (inputs) home-manager nixpkgs;
  inherit (import ../../lib { inherit inputs; }) versions;
in
home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.aarch64-darwin;
  extraSpecialArgs = {
    username = "drakebott";
    root = ../../.;
    inherit inputs versions;
  };
  modules = [
    ./configuration.nix
    ../../util/default.nix
    ../../home.nix
    ../../home/darwin/default.nix
    ../../home/common/default.nix
  ];
}
