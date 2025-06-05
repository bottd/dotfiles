{ inputs, ... }:
let
  inherit (inputs) home-manager nixpkgs;
in
home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.aarch64-darwin;
  extraSpecialArgs = {
    username = "drakebott";
    root = ../../.;
    neorgWorkspace = "notes";
    inherit inputs;
  };
  modules = [
    ./configuration.nix
    ../../util/default.nix
    ../../home.nix
    ../../home/darwin/default.nix
    ../../home/common/default.nix
  ];
}
