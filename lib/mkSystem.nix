{ inputs, ... }: { hostName
                 , system
                 , username
                 , format
                 , hostPath ? null
                 , extraSystemModules ? [ ]
                 , extraHomeModules ? [ ]
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
    nixpkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
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
            inputs.catppuccin.homeManagerModules.catppuccin
            ../home.nix
            ../lib/createSymlink.nix
            ../home/common
          ]
          ++ (
            if format == "nixos"
            then [ ../home/linux ]
            else [ ../home/darwin ]
          )
          ++ extraHomeModules;
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
      then [ inputs.catppuccin.nixosModules.catppuccin ../system/nixOS ]
      else [ ]
    )
    ++ extraSystemModules;
}
