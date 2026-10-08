{
  inputs,
  mkSpecialArgs,
  mkHomeModules,
}:
host:
inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = import inputs.nixpkgs {
    inherit (host) system;
    config.allowUnfree = true;
  };
  extraSpecialArgs = mkSpecialArgs host;
  modules = mkHomeModules host;
}
