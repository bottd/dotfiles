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
    else ../home/hosts/${hostName};
in
  inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    extraSpecialArgs = {
      inherit inputs host username system;
      inherit (inputs) nixpkgs;
      paths = {
        root = ../.;
        hosts = ../hosts;
        system = ../system;
        home = ../home;
        homeCommon = ../home/common;
        homeDarwin = ../home/darwin;
        homeLinux = ../home/linux;
        homeHosts = ../home/hosts;
        lib = ../lib;
      };
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
