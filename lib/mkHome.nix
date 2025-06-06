{ inputs, ... }: { hostName
                 , system
                 , username
                 , format
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
      inputs.spicetify-nix.homeManagerModules.default
      ../home.nix
      ../home/common
      path
    ]
    ++ (
      if format == "nixos"
      then [ ../home/linux ../home/linux/hyprland/host/desktop.nix ]
      else [ ../home/darwin ]
    )
    ++ extraHomeModules;
}
