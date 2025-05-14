{inputs ? {}, ...}:
let
  # Import all module functions with inputs
  createSymlink = import ./createSymlink.nix;
  mkHome = import ./mkHome.nix { inherit inputs; };
  mkSystem = import ./mkSystem.nix { inherit inputs; };
in
{
  # Re-export the functions
  inherit createSymlink mkHome mkSystem;
}
