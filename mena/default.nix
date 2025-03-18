{
  inputs,
  home-manager,
  mac-app-util,
  nixpkgs,
  ...
}:
home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.aarch64-darwin;
  extraSpecialArgs = {
    username = "mena";
    root = ../.;
  };
  modules = [
    ./configuration.nix
    ../../util/default.nix
    ../../home.nix
    ../../home/default.nix
  ];
}
