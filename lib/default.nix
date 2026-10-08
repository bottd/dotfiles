{
  inputs ? { },
  ...
}:
let
  inherit (inputs.nixpkgs) lib;
  inventory = import ./inventory.nix { inherit lib; } (import ../hosts);
  systems = lib.unique (map (host: host.system) (builtins.attrValues inventory));
  # One nixpkgs-unstable instance per system, shared across every mkSystem
  # call — re-importing it per host re-evaluates the whole nixpkgs fixpoint.
  unstableFor = lib.genAttrs systems (
    system:
    import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    }
  );

  mkSpecialArgs = host: {
    inherit inputs host;
    inherit (host)
      username
      system
      hostName
      theme
      features
      ;
    nixpkgs-unstable = unstableFor.${host.system};
  };

  mkSystem = import ./mkSystem.nix { inherit inputs mkSpecialArgs; };
  mkHomeModules =
    host:
    [
      inputs.stylix.homeModules.stylix
      ../home.nix
      ../hosts/${host.hostName}
    ]
    ++ host.extraHomeModules;
  mkHome = import ./mkHome.nix { inherit inputs mkSpecialArgs mkHomeModules; };
in
{
  inherit
    inventory
    systems
    mkSystem
    mkHome
    mkHomeModules
    mkSpecialArgs
    ;
}
