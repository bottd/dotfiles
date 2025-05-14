# Development shell module for flake-parts
{
  inputs,
  config,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    # Development shell
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        git
        config.treefmt.config.build.wrapper
      ];

      shellHook = ''
        echo "🚀 Welcome to Drake's dotfiles dev shell"
        echo "Use 'treefmt' to format the code, replacing alejandra"
      '';
    };
  };
}
