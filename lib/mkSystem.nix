{ inputs, ... }: { hostName
                 , system
                 , username
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
            inputs.catppuccin.homeModules.catppuccin
            inputs.spicetify-nix.homeManagerModules.default
            ../home.nix
            ../lib/createSymlink.nix
            ../home/common
            ../home/darwin
          ]
          ++ extraHomeModules;
      };
    };
  };
in
inputs.nix-darwin.lib.darwinSystem {
  inherit system;
  specialArgs = specialArgs;
  modules =
    [
      path
      inputs.home-manager.darwinModules.home-manager
      homeConfig
    ]
    ++ extraSystemModules;
}
