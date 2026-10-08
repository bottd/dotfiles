_: {
  perSystem = { pkgs, lib, ... }: {
    # Reuse the package definitions used by the hosts, and expose them for
    # independent native builds rather than relying on system evaluation.
    packages = {
      seo = pkgs.callPackage ../home/desktop/ai/seo/package.nix { };
      janet-modules = pkgs.callPackage ../packages/janet { };
      janet-lsp = pkgs.callPackage ../home/common/neovim/janet/janet-lsp.nix {
        spork = pkgs.callPackage ../packages/janet/spork.nix { };
      };
      inherit (import ../scripts { inherit pkgs; }) rebuild;
    }
    // lib.optionalAttrs pkgs.stdenv.isLinux (
      {
        shurectl = pkgs.callPackage ../hosts/desktop/shurectl.nix { };
        icy-draw = pkgs.callPackage ../home/linux/icy-draw { };
      }
      // lib.genAttrs [ "qmltermwidget-light" "qmltermwidget-dark" ] (
        name:
        pkgs.callPackage ../home/linux/niri/qmltermwidget.nix {
          colors =
            (import ../lib/stylixScheme.nix {
              inherit pkgs;
              scheme = "melange";
              appearance = lib.removePrefix "qmltermwidget-" name;
            }).base16Scheme;
        }
      )
    );
  };
}
