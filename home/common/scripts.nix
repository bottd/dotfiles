{ pkgs, ... }:
let
  scripts = import ./../../scripts { inherit pkgs; };
in
{
  home.packages = builtins.attrValues scripts;
}
