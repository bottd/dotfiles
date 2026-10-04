{
  self,
  ...
}:
{
  perSystem =
    { pkgs, config, ... }:
    let
      inherit (pkgs) lib;
      scripts = import ../scripts { inherit pkgs; };
      janetModules = pkgs.callPackage ../packages/janet { };
      checkJanet = pkgs.callPackage ../lib/checkJanet.nix { };

      selftest =
        name:
        pkgs.runCommand "${name}-selftest" { } ''
          export HOME="$TMPDIR"
          ${lib.getExe scripts.${name}} selftest
          touch $out
        '';
    in
    {
      treefmt = {
        projectRootFile = "flake.nix";
        # The pre-commit check already runs treefmt, including in CI.
        flakeCheck = false;
        programs = {
          nixfmt.enable = true;
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
            options = [
              "-n"
              "-f"
            ];
            includes = [ "*.janet" ];
          };
          qmlformat = {
            command = "${pkgs.qt6Packages.qtdeclarative}/bin/qmlformat";
            options = [
              "--inplace"
              "--indent-width"
              "4"
            ];
            includes = [ "*.qml" ];
          };
        };
      };

      checks = {
        inventory =
          assert import ../tests/inventory.nix { inherit lib; };
          pkgs.runCommand "host-inventory-tests" { } "touch $out";

        janet = pkgs.runCommand "janet-lint" { } ''
          export HOME="$TMPDIR"
          ${lib.concatMapStringsSep "\n" (file: "${checkJanet} ${lib.escapeShellArg "${file}"}") (
            lib.filter (file: lib.hasSuffix ".janet" (toString file)) (lib.filesystem.listFilesRecursive self)
          )}
          touch $out
        '';
        nvim-after = pkgs.callPackage ../home/common/neovim/compile-after.nix { };
      }
      // lib.genAttrs (lib.attrNames (lib.filterAttrs (_: script: script.hasSelftest) scripts)) selftest;

      pre-commit.settings.hooks = {
        treefmt.enable = true;
        statix.enable = true;
        deadnix.enable = true;
        actionlint = {
          enable = true;
          files = "^\\.forgejo/workflows/";
          entry = "${lib.getExe pkgs.actionlint} -config-file .forgejo/actionlint.yaml";
        };
      };

      devShells.default = pkgs.mkShell {
        inherit (config.pre-commit.devShell) shellHook;
        buildInputs =
          with pkgs;
          [
            git
            fnlfmt
            janet
            janetModules
            nh
            nixd
            nixfmt
            nodejs
            pnpm
          ]
          ++ config.pre-commit.settings.enabledPackages;
        JANET_PATH = "${janetModules}/lib";
      };
    };
}
