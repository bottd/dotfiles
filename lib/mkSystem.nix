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

  systemBuilder =
    if host.format == "nixos"
    then inputs.nixpkgs.lib.nixosSystem
    else if host.format == "darwin"
    then inputs.nix-darwin.lib.darwinSystem
    else throw "Unsupported system format: ${host.format}";
in
  systemBuilder {
    inherit system;
    specialArgs = {
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
    };
    modules =
      [
        path
        (
          if host.format == "nixos"
          then inputs.home-manager.nixosModules.home-manager
          else inputs.home-manager.darwinModules.home-manager
        )
      ]
      ++ extraModules;
  }
