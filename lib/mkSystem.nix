{ inputs, ... }: { hostName
                 , system
                 , username
                 , format
                 , hostPath ? null
                 , extraModules ? [ ]
                 ,
                 }:
let
  path =
    if hostPath != null
    then hostPath
    else ../hosts/${hostName};

  systemBuilder =
    if format == "nixos"
    then inputs.nixpkgs.lib.nixosSystem
    else if format == "darwin"
    then inputs.nix-darwin.lib.darwinSystem
    else throw "Unsupported system format: ${format}";

  homeManagerModule =
    if format == "nixos"
    then inputs.home-manager.nixosModules.home-manager
    else inputs.home-manager.darwinModules.home-manager;

  # Simple special args to avoid recursion
  specialArgs = {
    inherit inputs username system;
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
            if format == "nixos"
            then [ ../home/linux ../home/linux/hyprland/host/desktop.nix ]
            else [ ../home/darwin ]
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
      if format == "nixos"
      then [ ../system/nixOS ]
      else [ ../system/darwin ]
    )
    ++ extraModules;
}
