{ pkgs, ... }:
let
  mpv-cut-src = pkgs.fetchFromGitHub {
    owner = "familyfriendlymikey";
    repo = "mpv-cut";
    rev = "5fdf2851ead158309b870e452013fe5ca04fb011";
    hash = "sha256-QJOEC+uoQPSkl5hR9cE6PGS+sxfDLYvSZYE6HjQmxoI=";
  };

  mpv-cut-config = pkgs.runCommand "mpv-cut-config.lua"
    {
      nativeBuildInputs = [ pkgs.fennel ];
    } ''
    fennel --compile --globals mp,utils,ACTIONS,ACTION,KEY_CUT,KEY_CANCEL_CUT,KEY_BOOKMARK_ADD,KEY_CYCLE_ACTION \
      ${./config.fnl} > $out
  '';
in
{
  home.packages = [ pkgs.mpv ];

  xdg.configFile = {
    "mpv/scripts/mpv-cut/main.lua".source = "${mpv-cut-src}/main.lua";
    "mpv-cut/config.lua".source = mpv-cut-config;
  };
}
