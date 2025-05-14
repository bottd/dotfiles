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

  homeManagerModule =
    if host.format == "nixos"
    then inputs.home-manager.nixosModules.home-manager
    else inputs.home-manager.darwinModules.home-manager;

  commonSpecialArgs = {
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

  # Home-manager configuration
  homeConfig = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs =
        commonSpecialArgs
        // {
          neorgWorkspace = "chalet";
          root = ../.;
        };
      users.${username} = {
        imports = [../home.nix ../lib ../home/linux ../home/linux/hyrpland/host/desktop.nix ../home/common];
      };
    };
  };
in
  systemBuilder {
    inherit system;
    specialArgs = commonSpecialArgs;
    modules =
      [
        path
        homeManagerModule
        homeConfig
      ]
      ++ extraModules;
  }
