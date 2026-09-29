{
  inputs,
  ...
}:
{
  imports = [
    inputs.pre-commit-hooks.flakeModule
    inputs.treefmt-nix.flakeModule

    ./apps.nix
    ./ci.nix
    ./formatter.nix
    ./hosts.nix
    ./packages.nix
  ];
}
