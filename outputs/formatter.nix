{ inputs
, ...
}: {
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

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

    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        git
        config.treefmt.build.wrapper
      ];

      shellHook = ''
        echo "🚀 Welcome to Drake's dotfiles dev shell"
      '';
    };
  };
}
