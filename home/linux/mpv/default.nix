{ config, pkgs, ... }:
let
  mpv-cut-src = pkgs.fetchFromGitHub {
    owner = "familyfriendlymikey";
    repo = "mpv-cut";
    rev = "5fdf2851ead158309b870e452013fe5ca04fb011";
    hash = "sha256-QJOEC+uoQPSkl5hR9cE6PGS+sxfDLYvSZYE6HjQmxoI=";
  };

  mpv-cut-config = pkgs.runCommand "mpv-cut-config.lua"
    {
      nativeBuildInputs = [ pkgs.luaPackages.fennel ];
    } ''
    fennel --compile --globals mp,utils,ACTIONS,ACTION,KEY_CUT,KEY_CANCEL_CUT,KEY_BOOKMARK_ADD,KEY_CYCLE_ACTION \
      ${./config.fnl} > $out
  '';
in
{
  programs.mpv = {
    enable = true;
    scriptOpts.osc = with config.lib.stylix.colors.withHashtag; {
      background_color = base00;
      timecode_color = base0D;
      title_color = base05;
      time_pos_color = base05;
      buttons_color = base05;
      small_buttonsL_color = base05;
      small_buttonsR_color = base05;
      top_buttons_color = base05;
      held_element_color = base03;
      time_pos_outline_color = base00;
    };
  };

  xdg.configFile = {
    "mpv/scripts/mpv-cut/main.lua".source = "${mpv-cut-src}/main.lua";
    "mpv-cut/config.lua".source = mpv-cut-config;
  };
}
