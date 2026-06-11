{ inputs
, ...
}: {
  imports = [
    inputs.pre-commit-hooks.flakeModule
    inputs.treefmt-nix.flakeModule

    ./formatter.nix
    ./hosts.nix
  ];
}
