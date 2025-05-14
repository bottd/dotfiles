{inputs, ...}: {
  hostName,
  system,
  username,
  format,
  hostPath ? null,
  extraModules ? [],
}: let
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
      neorgWorkspace = "chalet";
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
        then [../home/linux ../home/linux/hyprland/host/desktop.nix]
        else [../home/darwin]
      )
      ++ extraModules;
  }
