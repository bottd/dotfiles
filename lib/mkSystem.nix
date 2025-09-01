{ inputs, ... }:
{ hostName
, system
, username
, format
, desktopEnvironment ? "plasma"
, hostPath ? null
, extraSystemModules ? [ ]
, extraHomeModules ? [ ]
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

  specialArgs = {
    inherit inputs username system desktopEnvironment hostName;
    inherit (inputs) nixpkgs nixos-hardware;
    nixpkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  };

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
            inputs.plasma-manager.homeModules.plasma-manager
            ../home.nix
            ../lib/createSymlink.nix
            ../home/common
          ]
          ++ (if format == "nixos" then [ ../home/linux ] else [ ../home/darwin ])
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
    ++ (if format == "nixos" then [
      inputs.catppuccin.nixosModules.catppuccin
      ../system/nixOS
    ] else [
      # Maybe supported in the future
      # https://github.com/catppuccin/nix/pull/477
      # inputs.catppuccin.darwinModules.catppuccin
    ])
    ++ extraSystemModules;
}
