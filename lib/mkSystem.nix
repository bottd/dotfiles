{ inputs, versions, mkSpecialArgs, ... }:
{ hostName
, system
, username
, format
, theme ? { }
, features ? { }
, hostPath ? null
, extraSystemModules ? [ ]
, extraHomeModules ? [ ]
, autologin ? false
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

  sharedArgs = mkSpecialArgs {
    inherit system username hostName theme features;
  };

  specialArgs = sharedArgs // { inherit autologin; };

  homeConfig = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = sharedArgs;

      users.${username} = {
        imports =
          [
            ../home.nix
            ../lib/createSymlink.nix
            ../home/common
          ]
          ++ (if format == "nixos" then [
            ../home/linux
          ] else [
            ../home/darwin
          ])
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
      inputs.stylix.nixosModules.stylix
      ../system/nixOS
      (_: { system.stateVersion = versions.nixos; })
    ]
    else if format == "nixos" then [
      inputs.stylix.nixosModules.stylix
      ../system/nixOS
      (_: { system.stateVersion = versions.nixos; })
    ]
    else if format == "darwin" then [
      inputs.stylix.darwinModules.stylix
      ../system/common/darwin
      (_: { system.stateVersion = versions.darwin; })
    ]
    else [
    ])
    ++ extraSystemModules;
}
