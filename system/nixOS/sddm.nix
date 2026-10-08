# The non-autologin greeter. Only imported for niri hosts.
{
  # X11 greeter, not Wayland. wlroots/cage and SDDM's Wayland greeter both
  # ignore the DRM panel-orientation property the kernel sets, and neither
  # exposes a rotation knob. The X11 greeter does, via setupScript — hosts with
  # a rotated panel set it themselves (see hosts/pocket). SDDM asserts that one
  # of xserver.enable / wayland.enable is set, so this line is load-bearing.
  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
}
