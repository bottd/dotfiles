{ inputs
, ...
}: {
  imports = [
    inputs.pre-commit-hooks.flakeModule
    inputs.treefmt-nix.flakeModule

    ./apps.nix
    ./formatter.nix
    ./hosts.nix
    ./packages.nix
  ];
}
