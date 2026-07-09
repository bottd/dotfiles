# niri outputs for the GPD Pocket. The internal panel is mounted portrait, so
# the primary output is rotated to landscape. CONFIRM the connector name +
# rotation on first boot:
#   niri msg outputs
# If the name isn't "DSI-1" (some units report "eDP-1"), rename below. If the
# image is sideways the wrong way, swap rotation 270 <-> 90.
_:
{
  programs.niri.settings.outputs = {
    "DSI-1" = {
      mode = { width = 1200; height = 1920; };
      scale = 1.5;
      transform.rotation = 270;
      position = { x = 0; y = 0; };
    };
  };
}
