# Dither Press tokens (DESIGN.md), resolved from Stylix once so every surface
# that draws the style — Quickshell's Theme.qml, Glide's chrome and new tab
# page — maps base16 slots to roles and sizes the same way.
{ config, lib, ... }:
let
  inherit (config.lib.stylix) colors;

  # Every size derives from the shell's base fontSize so the eink host (base
  # 20) scales instead of overflowing a layout tuned for 12. Comments give the
  # value at 12.
  fontSize = config.stylix.fonts.sizes.terminal;
  round = x: builtins.floor (x + 0.5);
  hairline = lib.max 2 (round (fontSize / 6.0));
  pressOffset = lib.max 3 (round (fontSize / 4.0));
in
{
  lib.ditherPress = {
    colors = lib.mapAttrs (_: slot: "#${colors.${slot}}") {
      paper = "base00";
      surface = "base01";
      hover = "base02";
      # Resting rules and borders; also the pressed fill.
      rule = "base03";
      # base04 is base16's muted-foreground slot in both polarities. base06,
      # which an older dark mapping used, isn't defined by melange (see
      # lib/stylixScheme.nix) and landed 1.07:1 against ink, so "muted" text
      # rendered at primary emphasis. base04 is a real step down: 2.04:1 dark,
      # 2.99:1 light.
      muted = "base04";
      ink = "base07";
      plate = "base09";
      danger = "base08";
      # base16's green and yellow. Blue and rose (base0D/base0F), which an
      # older light mapping used, read "connected" as informational and put
      # warning closer in hue to danger than to caution, at 2.80:1 on paper.
      positive = "base0B";
      warning = "base0A";
    };

    font = config.stylix.fonts.monospace.name;

    sizes = {
      font = fontSize; # 12
      heading = round (fontSize * 1.4); # 17
      caption = fontSize - 2; # 10
      rule = hairline; # 2
      plateOffset = hairline; # 2
      inherit pressOffset; # 3
      panelOffset = pressOffset * 2; # 6
      gap = fontSize; # 12
      # Tight spacing inside a row or tag.
      halfGap = round (fontSize / 2.0); # 6
      inset = round (fontSize * 1.5); # 18
      # A list row's icon tile.
      tile = fontSize * 2; # 24
      # The halftone band where paper breaks up into what's behind it.
      seam = round (fontSize / 2.0); # 6
      seamCell = 2;
    };
  };
}
