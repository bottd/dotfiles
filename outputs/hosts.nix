{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
  inherit (import ../lib { inherit inputs; }) inventory mkSystem;
  mkWithVariants =
    name: host:
    let
      base = mkSystem host;
    in
    {
      ${name} = base;
    }
    // lib.genAttrs (map (appearance: "${name}-${appearance}") host.appearances) (
      variant:
      let
        appearance = lib.removePrefix "${name}-" variant;
      in
      if appearance == host.theme.appearance then
        base
      else
        mkSystem (
          host
          // {
            theme = host.theme // {
              inherit appearance;
            };
          }
        )
    );
  configurations =
    format:
    lib.concatMapAttrs mkWithVariants (lib.filterAttrs (_: host: host.format == format) inventory);
in
{
  flake = {
    hostInventory = inventory;
    nixosConfigurations = configurations "nixos";
    darwinConfigurations = configurations "darwin";
  };
}
