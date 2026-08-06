{ pkgs, ... }:
let
  scripts = import ./../../scripts { inherit pkgs; };
in
{
  # tresorit-install pins a ~107 MB installer blob and is a one-shot bootstrap,
  # so it stays out of every generation's closure and is realised on demand via
  # `nix run .#tresorit-install` instead.
  home.packages = builtins.attrValues (builtins.removeAttrs scripts [ "tresorit-install" ]);
}
