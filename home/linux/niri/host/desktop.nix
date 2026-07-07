# niri config for the desktop. Monitor layout mirrors the old KDE setup
# (via kscreen-doctor):
#   DP-1  2560x1440 landscape, main
#   DP-3  rotated 270° portrait panel to its right (logical 1440x2560)
# If a monitor comes up upside-down, swap rotation 270 <-> 90.
_:
{
  programs.niri.settings = {
    # niri-vert-scroll (scripts/niri-vert-scroll.clj) makes portrait outputs
    # one vertical scrolling column; only this host has one (DP-3).
    spawn-at-startup = [{ argv = [ "niri-vert-scroll" ]; }];

    outputs = {
      "DP-1" = {
        mode = { width = 2560; height = 1440; };
        scale = 1.0;
        position = { x = 0; y = 282; };
      };

      # Portrait. niri has no native vertical layout (issue #1071) and the
      # typed outputs DSL has no per-output layout option — niri-vert-scroll
      # (spawned above) handles it.
      "DP-3" = {
        mode = { width = 2560; height = 1440; };
        scale = 1.0;
        transform.rotation = 270;
        position = { x = 2560; y = 0; };
      };
    };
  };
}
