{ config, lib, ... }:
let
  root = "${config.home.homeDirectory}/QuoteMC";
in
{
  # umbrella dir for this profile's MC state; prism/ keeps Prism scoped to it
  home.activation.quoteSandbox =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p '${root}' '${root}/.cache' '${root}/prism'
    '';
}
