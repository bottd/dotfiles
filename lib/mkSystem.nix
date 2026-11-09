{ inputs, mkSpecialArgs, ... }:
host@{
  hostName,
  system,
  username,
  format,
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
        # Host-specific home config sits next to the host's system module.
        ++ inputs.nixpkgs.lib.optional (builtins.pathExists (path + "/home.nix")) (path + "/home.nix");
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
