{ inputs
, ...
}: {
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.pre-commit-hooks.flakeModule

    ./lib.nix
    ./formatter.nix
    ./hosts.nix
    ./home-manager.nix
    ./systems.nix
  ];
}
