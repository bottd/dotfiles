{inputs, ...}: {
  hostName,
  hostPath ? null,
  extraModules ? [],
}: let
  hosts = import ../hosts.nix;
  host = hosts.hosts.${hostName};
  system = host.system;
  username = host.username;

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
      inherit inputs host username system;
      inherit (inputs) nixpkgs;
      neorgWorkspace = "chalet";
      root = ../.;
    };

    modules =
      [
        ../home.nix
        path
      ]
      ++ extraModules;
  }
