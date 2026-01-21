{ inputs, versions, mkSpecialArgs, ... }:
{ hostName
, system
, username
, format
, desktopEnvironment ? null
, includeGui ? true
, includeGaming ? false
, hostPath ? null
, extraSystemModules ? [ ]
, extraHomeModules ? [ ]
, enableAVF ? false
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

  specialArgs = mkSpecialArgs {
    inherit system username desktopEnvironment hostName includeGui includeGaming;
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
            ../home.nix
            ../lib/createSymlink.nix
            ../home/common
          ]
          ++ (if format == "nixos" then [
            inputs.plasma-manager.homeModules.plasma-manager
            ../home/linux
          ] else [ ../home/darwin ])
          ++ extraHomeModules;
      };
    };
  };
in
systemBuilder {
  inherit system;
  inherit specialArgs;
  modules =
    [
      path
      homeManagerModule
      homeConfig
    ]
    ++ (if enableAVF then [
      inputs.nixos-avf.nixosModules.avf
      (_: { system.stateVersion = versions.nixos; })
    ]
    else if format == "nixos" then [
      inputs.catppuccin.nixosModules.catppuccin
      ../system/nixOS
      (_: { system.stateVersion = versions.nixos; })
    ]
    else if format == "darwin" then [
      (_: { system.stateVersion = versions.darwin; })
    ]
    else [
    ])
    ++ extraSystemModules;
}
