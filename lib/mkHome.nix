{ inputs, mkSpecialArgs, ... }:
{ hostName
, system
, username
, format
, desktopEnvironment ? null
, hostPath ? null
, extraHomeModules ? [ ]
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

  extraSpecialArgs = mkSpecialArgs
    {
      inherit system username desktopEnvironment;
    } // {
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
      then [
        ../home/linux
      ]
      else [ ../home/darwin ]
    )
    ++ extraHomeModules;
}
