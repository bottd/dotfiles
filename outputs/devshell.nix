_:
{
  perSystem = { pkgs, config, ... }: {
    devShells.default = pkgs.mkShell {
      inherit (config.pre-commit.devShell) shellHook;
      buildInputs = with pkgs; [
        git
        config.treefmt.build.wrapper
        fnlfmt
        cljfmt
        clj-kondo
        nodejs
        pnpm
        statix
      ] ++ config.pre-commit.settings.enabledPackages;
    };
  };
}
