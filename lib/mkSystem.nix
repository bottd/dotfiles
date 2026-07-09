{ inputs, mkSpecialArgs, ... }:
{ hostName
, system
, username
, format
, theme ? { }
, features ? { }
, extraHomeModules ? [ ]
, autologin ? false
, enableAVF ? false
}:
let
  path = ../hosts/${hostName};

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
      ../system/users
      homeManagerModule
      homeConfig
      { time.timeZone = "America/Chicago"; }
    ]
    ++ (if enableAVF then [
      inputs.nixos-avf.nixosModules.avf
      inputs.stylix.nixosModules.stylix
      ../system/common/stylix.nix
      ../system/common/nix.nix
      (_: {
        system.stateVersion = "25.05";
        stylix.targets.grub.enable = false;
      })
    ]
    else if format == "nixos" then [
      inputs.stylix.nixosModules.stylix
      ../system/nixOS
      (_: { system.stateVersion = "25.05"; })
    ]
    else [
      inputs.stylix.darwinModules.stylix
      ../system/common/darwin
      (_: { system.stateVersion = 6; })
    ]);
}
