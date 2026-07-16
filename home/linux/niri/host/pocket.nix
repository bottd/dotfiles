# niri outputs for the GPD Pocket 4. The connector is eDP-1 (see nixos-hardware
# gpd/pocket-4, which also pins the panel orientation via kernel `video=` —
# so niri lands landscape without a transform here).
#
# Only the scale is ours: at ~343 dpi niri auto-picks 2.0, which is too big.
# Verify with `niri msg outputs` if anything looks off.
_:
{
  programs.niri.settings.outputs."eDP-1" = {
    # The panel's native 60 Hz mode avoids driving it at 144 Hz on battery.
    mode = {
      width = 1600;
      height = 2560;
      refresh = 60.0;
    };
    scale = 1.5;
  };
}
