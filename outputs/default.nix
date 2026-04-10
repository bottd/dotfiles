{ inputs
, ...
}: {
  imports = [
    inputs.pre-commit-hooks.flakeModule
    inputs.treefmt-nix.flakeModule

    ./formatter.nix
    ./home-manager.nix
    ./hosts.nix
    ./lib.nix
    ./systems.nix
  ];
}
