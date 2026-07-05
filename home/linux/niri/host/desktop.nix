# niri `output` blocks for the desktop, imported as a string by ../default.nix.
# Layout mirrors the current KDE setup (detected via kscreen-doctor):
#   DP-1  2560x1440 landscape, main
#   DP-3  rotated 270° portrait panel to its right (logical 1440x2560)
# If a monitor comes up upside-down, swap transform "270" <-> "90".
''
  output "DP-1" {
      mode "2560x1440"
      scale 1.0
      transform "normal"
      position x=0 y=282
  }

  output "DP-3" {
      mode "2560x1440"
      scale 1.0
      transform "270"
      position x=2560 y=0
  }
''
