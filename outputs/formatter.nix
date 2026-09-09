{ self
, ...
}: {
  perSystem = { pkgs, config, ... }:
    let
      inherit (pkgs) lib;
      scripts = import ../scripts { inherit pkgs; };
      janetModules = pkgs.callPackage ../packages/janet { };
      checkJanet = pkgs.callPackage ../lib/checkJanet.nix { };

      # Scripts carrying a `selftest` subcommand run it here — an unrun check
      # rots. Runs the packaged bin, so the wrapper that actually ships is what
      # gets exercised.
      selftest = name: pkgs.runCommand "${name}-selftest" { } ''
        export HOME="$TMPDIR"
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
          janet-format = {
            command = "${janetModules}/bin/janet-format";
            options = [ "-n" "-f" ];
            includes = [ "*.janet" ];
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

        janet = pkgs.runCommand "janet-lint" { } ''
          export HOME="$TMPDIR"
          ${lib.concatMapStringsSep "\n"
            (file: "${checkJanet} ${lib.escapeShellArg "${file}"}")
            (lib.filter (file: lib.hasSuffix ".janet" (toString file))
              (lib.filesystem.listFilesRecursive ../scripts)
            ++ [ ../home/common/neovim/compile-after.janet ])}
          touch $out
        '';
        script-commands = import ../tests/scripts.nix { inherit pkgs; };
        janet-compiler = import ../tests/janet-compiler.nix { inherit pkgs; };
        nvim-after = pkgs.callPackage ../home/common/neovim/compile-after.nix { };
      } // lib.genAttrs [ "brightness" "darwin-sign-apps" "niri-layout" "waybar-mullvad" ] selftest;

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
          janet
          janetModules
          nodejs
          pnpm
        ] ++ config.pre-commit.settings.enabledPackages;
        JANET_PATH = "${janetModules}/lib";
      };
    };
}
