# Development tools module
{inputs, ...}: {
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    system,
    ...
  }: {
    # Formatter configuration
    formatter =
      inputs.treefmt-nix.lib.mkWrapper
      pkgs
      {
        projectRootFile = "flake.nix";
        programs = {
          nixpkgs-fmt.enable = true;
          stylua.enable = true;
          shfmt.enable = true;
          beautysh.enable = true;
          deadnix.enable = true;
          taplo.enable = true;
        };
      };

    # Development shell
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        git
        self'.formatter
      ];

      shellHook = ''
        echo "🚀 Welcome to Drake's dotfiles dev shell"
        echo "Use 'treefmt' to format the code, replacing alejandra"
      '';
    };
  };
}
