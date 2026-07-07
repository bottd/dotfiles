{ inputs, versions, mkSpecialArgs, homeImports, ... }:
{ hostName
, system
, username
, theme ? { }
, features ? { }
, hostPath ? null
, extraSystemModules ? [ ]
, extraHomeModules ? [ ]
}:
let
  path =
    if hostPath != null
    then hostPath
    else ../hosts/${hostName};

  sharedArgs = mkSpecialArgs {
    inherit username hostName theme features;
  };

  homeConfig = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = sharedArgs;
      users.${username}.imports = homeImports ++ extraHomeModules;
    };
  };
in
inputs.nix-darwin.lib.darwinSystem {
  inherit system;
  specialArgs = sharedArgs;
  modules =
    [
      path
      inputs.home-manager.darwinModules.home-manager
      homeConfig
      ../system/common/darwin
      ../system/common/time.nix
      (_: { system.stateVersion = versions.darwin; })
    ]
    ++ extraSystemModules;
}
