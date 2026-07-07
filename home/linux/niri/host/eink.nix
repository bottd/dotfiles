# niri extras for the eink box (e-ink monitor), ported from the old sway
# setup. No outputs block: connector name unconfirmed, niri auto-configures;
# pin one down with `niri msg outputs` if needed.
{ config, lib, pkgs, theme, ... }:
{
  home.packages = with pkgs; [
    foliate
    zathura
  ];

  programs.niri.settings = {
    # E-ink: animations just smear into ghosting.
    animations.enable = false;
    # Old sway setup: seat * hide_cursor 3000.
    cursor.hide-after-inactive-ms = 3000;
    # White backdrop + zero gaps (old sway: `bg #ffffff solid_color`, gaps 0)
    # — niri's default dark backdrop is a permanent dark field on the panel.
    layout = {
      background-color = "#ffffff";
      gaps = lib.mkForce 0;
    };
    # Don't drag the cursor across the panel on keyboard focus changes.
    input.warp-mouse-to-focus.enable = lib.mkForce false;

    spawn-at-startup = [{ argv = [ "ghostty" ]; }];

    binds = with config.lib.niri.actions; {
      "Mod+N".action = spawn "ghostty" "-e" "nvim";
      "Mod+B".action = spawn "foliate";
    };
  };

  # Big legible launcher (ported from the old sway host file); stylix's
  # fuzzel target otherwise lands at ~10pt sans on a 20pt-baseline panel.
  programs.fuzzel.settings = {
    main = {
      font = lib.mkForce "MonoLisa Nerd Font:size=${toString (theme.baseFontSize + 2)}";
      lines = 10;
      width = 40;
      horizontal-pad = 20;
      vertical-pad = 10;
    };
    border.width = 2;
  };
}
