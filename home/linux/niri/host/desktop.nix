# niri `outputs` for the desktop, imported as an attrset by ../default.nix
# into settings.outputs. Layout mirrors the KDE setup (via kscreen-doctor):
#   DP-1  2560x1440 landscape, main
#   DP-3  rotated 270° portrait panel to its right (logical 1440x2560)
# If a monitor comes up upside-down, swap rotation 270 <-> 90.
{
  "DP-1" = {
    mode = { width = 2560; height = 1440; };
    scale = 1.0;
    position = { x = 0; y = 282; };
  };

  # Portrait. niri-vert-scroll (scripts/niri-vert-scroll.clj) makes this a
  # single vertical scrolling column — niri has no native vertical layout
  # (issue #1071). The typed outputs DSL has no per-output layout option, so
  # the script also widens the consolidated column to 100% itself.
  "DP-3" = {
    mode = { width = 2560; height = 1440; };
    scale = 1.0;
    transform.rotation = 270;
    position = { x = 2560; y = 0; };
  };
}
