# niri outputs for the GPD Pocket 4. The connector is eDP-1 (see nixos-hardware
# gpd/pocket-4, which also pins the panel orientation via kernel `video=` —
# so niri lands landscape without a transform here).
#
# Only the scale is ours: at ~343 dpi niri auto-picks 2.0, which is too big.
# Verify with `niri msg outputs` if anything looks off.
_:
{
  programs.niri.settings.outputs."eDP-1".scale = 1.5;
}
