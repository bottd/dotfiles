# niri `output` block for the GPD Pocket, imported as a string by ../default.nix.
# The internal panel is mounted portrait, so the primary output is rotated to
# landscape. CONFIRM the connector name + rotation on first boot:
#   niri msg outputs
# If the name isn't "DSI-1" (some units report "eDP-1"), rename below. If the
# image is sideways the wrong way, swap transform "270" <-> "90".
''
  output "DSI-1" {
      mode "1200x1920"
      scale 1.5
      transform "270"
      position x=0 y=0
  }
''
