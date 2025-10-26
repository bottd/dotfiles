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
        stylua.enable = true;
        shfmt.enable = true;
        beautysh.enable = true;
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

      settings.formatter = {
        fnlfmt = {
          command = "${pkgs.fnlfmt}/bin/fnlfmt";
          options = [ "--fix" ];
          includes = [ "*.fnl" ];
        };
        cljfmt = {
          command = "${pkgs.cljfmt}/bin/cljfmt";
          options = [ "fix" ];
          includes = [ "*.clj" "*.cljs" "*.cljc" "*.edn" "*.bb" ];
        };
        clj-kondo = {
          command = "${pkgs.clj-kondo}/bin/clj-kondo";
          options = [ "--lint" ];
          includes = [ "*.clj" "*.cljs" "*.cljc" "*.edn" "*.bb" ];
        };
      };
    };

    checks = {
      formatting = config.treefmt.build.check self;
    };

    pre-commit.settings.hooks = {
      treefmt.enable = true;
      statix.enable = true;
      deadnix.enable = true;
    };

    devShells.default = pkgs.mkShell {
      inherit (config.pre-commit.devShell) shellHook;
      buildInputs = with pkgs; [
        git
        config.treefmt.build.wrapper
        fnlfmt
        cljfmt
        clj-kondo
        statix
      ] ++ config.pre-commit.settings.enabledPackages;
    };
  };
}
