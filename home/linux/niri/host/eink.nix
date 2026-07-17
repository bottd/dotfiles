# niri extras for the eink box (e-ink monitor), ported from the old sway
# setup. No outputs block: connector name unconfirmed, niri auto-configures;
# pin one down with `niri msg outputs` if needed.
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    foliate
    zathura
  ];

  programs.niri.settings = {
    # E-ink: animations just smear into ghosting.
    animations.enable = false;
    cursor.hide-after-inactive-ms = 3000;
    # White backdrop + zero gaps (old sway: `bg #ffffff solid_color`, gaps 0)
    # — niri's default dark backdrop is a permanent dark field on the panel,
    # and the scheme's off-white (#fafbfc) is worse than pure white on e-ink.
    layout = {
      background-color = "#ffffff";
      gaps = 0;
    };
    # Don't drag the cursor across the panel on keyboard focus changes.
    input.warp-mouse-to-focus.enable = false;

    spawn-at-startup = [{ argv = [ "ghostty" ]; }];

    binds = with config.lib.niri.actions; {
      "Mod+N".action = spawn "ghostty" "-e" "nvim";
      "Mod+B".action = spawn "foliate";
    };
  };

}
