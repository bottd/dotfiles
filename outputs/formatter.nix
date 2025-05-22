{ self
, ...
}: {
  perSystem = { pkgs, config, ... }: {
    treefmt = {
      projectRootFile = "flake.nix";
      programs = {
        nixpkgs-fmt.enable = true;
        stylua.enable = true;
        shfmt.enable = true;
        beautysh.enable = true;
        deadnix.enable = true;
        taplo.enable = true;
        prettier = {
          enable = true;
          settings = {
            printWidth = 80;
            proseWrap = "always";
            tabWidth = 2;
          };
        };
      };
    };

    checks.formatting = config.treefmt.build.check self;

    pre-commit.settings.hooks.treefmt.enable = true;

    devShells.default = pkgs.mkShell {
      inherit (config.pre-commit.devShell) shellHook;
      buildInputs = with pkgs; [
        git
        config.treefmt.build.wrapper
      ] ++ config.pre-commit.settings.enabledPackages;
    };
  };
}
