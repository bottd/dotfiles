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
in
{
  inherit inventory systems mkSystem;
}
