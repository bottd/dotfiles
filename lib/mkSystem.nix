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

  # Simple special args to avoid recursion
  specialArgs = {
    inherit inputs host username system;
    inherit (inputs) nixpkgs;
  };

  # Home-manager configuration module
  homeConfig = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = specialArgs;
      users.${username} = {
        imports =
          [
            ../home.nix
            ../lib/createSymlink.nix
            ../home/common
          ]
          ++ (
            if host.format == "nixos"
            then [../home/linux ../home/linux/hyprland/host/desktop.nix]
            else [../home/darwin]
          );
      };
    };
  };
in
  systemBuilder {
    inherit system;
    specialArgs = specialArgs;
    modules =
      [
        path
        homeManagerModule
        homeConfig
      ]
      ++ (
        if host.format == "nixos"
        then [../system/nixOS]
        else [../system/darwin]
      )
      ++ extraModules;
  }
