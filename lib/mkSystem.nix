{ inputs, mkSpecialArgs, ... }:
host@{
  hostName,
  system,
  username,
  format,
  extraHomeModules,
  extraSystemModules,
  autologin,
  stateVersion,
  ...
}:
let
  path = ../hosts/${hostName};

  systemBuilder =
    if format == "nixos" then
      inputs.nixpkgs.lib.nixosSystem
    else if format == "darwin" then
      inputs.nix-darwin.lib.darwinSystem
    else
      throw "Unsupported system format: ${format}";

  homeManagerModule =
    if format == "nixos" then
      inputs.home-manager.nixosModules.home-manager
    else
      inputs.home-manager.darwinModules.home-manager;

  sharedArgs = mkSpecialArgs host;

  specialArgs = sharedArgs // {
    inherit autologin;
  };

  homeConfig = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = sharedArgs;

      users.${username} = {
        imports = [
          ../home.nix
          ../home/common
        ]
        ++ inputs.nixpkgs.lib.optional (host.features.desktopEnvironment != null) ../home/desktop
        ++ (
          if format == "nixos" then
            [
              ../home/linux
            ]
          else
            [
              ../home/darwin
            ]
        )
        ++ extraHomeModules;
      };
    };
  };
in
systemBuilder {
  inherit system;
  inherit specialArgs;
  modules = [
    path
    ../system/users
    ../system/common
    homeManagerModule
    homeConfig
    {
      time.timeZone = "America/Chicago";
      system.stateVersion = stateVersion.system;
    }
  ]
  ++ extraSystemModules
  ++ inputs.nixpkgs.lib.optional (format == "nixos") ../system/common/nixos.nix
  ++ (
    if format == "nixos" then
      [
        inputs.stylix.nixosModules.stylix
        ../system/nixOS
      ]
    else
      [
        inputs.stylix.darwinModules.stylix
        ../system/common/darwin
      ]
  );
}
