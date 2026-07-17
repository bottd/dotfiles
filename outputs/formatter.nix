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
        qmlformat = {
          command = "${pkgs.qt6Packages.qtdeclarative}/bin/qmlformat";
          options = [ "--inplace" "--indent-width" "4" ];
          includes = [ "*.qml" ];
        };
      };
    };

    checks = {
      formatting = config.treefmt.build.check self;

      # Scripts carrying a `selftest` subcommand run it here — an unrun check rots.
      waybar-mullvad = pkgs.runCommand "waybar-mullvad-selftest" { } ''
        ${(import ../scripts { inherit pkgs; }).waybar-mullvad}/bin/waybar-mullvad selftest
        touch $out
      '';
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
        fnlfmt
        cljfmt
        clj-kondo
        nodejs
        pnpm
      ] ++ config.pre-commit.settings.enabledPackages;
    };
  };
}
