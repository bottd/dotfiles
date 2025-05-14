# Formatter configuration module for flake-parts
{inputs, ...}: {
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = {
    config,
    pkgs,
    ...
  }: {
    treefmt.config = {
      projectRootFile = "flake.nix";
      programs = {
        nixpkgs-fmt.enable = true;
        stylua.enable = true;
        shfmt.enable = true;
        beautysh.enable = true;
        deadnix.enable = true;
        taplo.enable = true;
      };
    };
  };
}
