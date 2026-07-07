{ self
, ...
}: {
  perSystem = { pkgs, config, ... }: {
    treefmt = {
      projectRootFile = "flake.nix";
      programs = {
        nixpkgs-fmt.enable = true;
        deadnix.enable = true;
        statix.enable = true;
      };
    };

    checks.formatting = config.treefmt.build.check self;

    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        git
        config.treefmt.build.wrapper
        statix
      ];
    };
  };
}
