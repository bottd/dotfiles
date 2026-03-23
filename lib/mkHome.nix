{ inputs, mkSpecialArgs, ... }:
{ hostName
, system
, username
, format
, desktopEnvironment ? null
, colorScheme ? "light"
, baseFontSize ? 12
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
      inherit system username desktopEnvironment colorScheme baseFontSize;
    } // {
    root = ../.;
  };

  modules =
    [
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
