{ inputs, ... }: { hostName
                 , system
                 , username
                 , hostPath ? null
                 , extraHomeModules ? [ ]
                 ,
                 }:
let
  path =
    if hostPath != null
    then hostPath
    else ../hosts/${hostName};
in
inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  extraSpecialArgs = {
    inherit inputs username system;
    inherit (inputs) nixpkgs;
    nixpkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    neorgWorkspace = "chalet";
    root = ../.;
  };

  modules =
    [
      inputs.catppuccin.homeModules.catppuccin
      ../home.nix
      ../home/common
      ../home/darwin
      path
    ]
    ++ extraHomeModules;
}
