# niri extras for the eink box (e-ink monitor), ported from the old sway
# setup. No outputs block: connector name unconfirmed, niri auto-configures;
# pin one down with `niri msg outputs` if needed.
{ config, ... }:
{
  programs = {
    foliate.enable = true;
    zathura.enable = true;
    niri.settings = {
      cursor.hide-after-inactive-ms = 3000;
      # White backdrop + zero gaps (old sway: `bg #ffffff solid_color`, gaps 0)
      # — niri's default dark backdrop is a permanent dark field on the panel,
      # and the scheme's off-white (#fafbfc) is worse than pure white on e-ink.
      layout = {
        background-color = "#ffffff";
        gaps = 0;
        # Zero gaps leave the plate offset nowhere to land but on the
        # neighbouring window, and e-ink renders its alpha as mud.
        shadow.enable = false;
        border.inactive.color = "#${config.lib.stylix.colors.base07}";
      };
      # Don't drag the cursor across the panel on keyboard focus changes.
      input.warp-mouse-to-focus.enable = false;

      spawn-at-startup = [ { argv = [ "ghostty" ]; } ];

      binds = with config.lib.niri.actions; {
        "Mod+N".action = spawn "ghostty" "-e" "nvim";
        "Mod+B".action = spawn "foliate";
      };
    };
  };

}
