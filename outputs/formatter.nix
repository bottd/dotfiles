{ self
, ...
}: {
  perSystem = { pkgs, config, ... }:
    let
      inherit (pkgs) lib;
      scripts = import ../scripts { inherit pkgs; };

      # Scripts carrying a `selftest` subcommand run it here — an unrun check
      # rots. Runs the packaged bin, so the wrapper that actually ships is what
      # gets exercised.
      selftest = name: pkgs.runCommand "${name}-selftest" { } ''
        ${lib.getExe scripts.${name}} selftest
        touch $out
      '';
    in
    {
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
          qmlformat = {
            command = "${pkgs.qt6Packages.qtdeclarative}/bin/qmlformat";
            options = [ "--inplace" "--indent-width" "4" ];
            includes = [ "*.qml" ];
          };
        };
      };

      checks = {
        formatting = config.treefmt.build.check self;

        # One invocation per file: these are namespace-less babashka scripts, so
        # linting them together collapses them into a single `user` namespace and
        # every shared require reads as a duplicate.
        clj-kondo = pkgs.runCommand "clj-kondo-lint" { } ''
          export HOME="$TMPDIR"
          for f in $(find ${../scripts} -name '*.clj'); do
            ${lib.getExe pkgs.clj-kondo} --lint "$f"
          done
          touch $out
        '';
      } // lib.genAttrs [ "darwin-sign-apps" "waybar-mullvad" ] selftest;

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
