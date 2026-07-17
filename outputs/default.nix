{ inputs
, ...
}: {
  imports = [
    inputs.pre-commit-hooks.flakeModule
    inputs.treefmt-nix.flakeModule

    ./devshell.nix
    ./formatter.nix
    ./hosts.nix
  ];
}
