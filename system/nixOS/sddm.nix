{ inputs, pkgs, features, ... }:
# The non-autologin greeter (pocket). Only imported for niri hosts.
assert features.desktopEnvironment == "niri";
{
  # X11 greeter, not Wayland. wlroots/cage and SDDM's Wayland greeter both
  # ignore the DRM panel-orientation property the kernel sets for this panel
  # (`video=eDP-1:panel_orientation=right_side_up`, from nixos-hardware's
  # gpd-pocket-4), and neither exposes a rotation knob. The X11 greeter does:
  # setupScript runs as root before the greeter starts, so xrandr can rotate it.
  # niri itself needs no transform — it honours the DRM property already.
  services.xserver.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false;
    theme = "minesddm";

    # If the greeter comes up upside down, swap `right` for `left`.
    setupScript = ''
      ${pkgs.xrandr}/bin/xrandr --output eDP-1 --rotate right
    '';
  };

  # SDDM looks for themes under /run/current-system/sw/share/sddm/themes.
  # We install the theme package directly rather than using the upstream
  # nixosModule, which pulls in Qt5 for a Qt6 theme.
  environment.systemPackages = [ inputs.minesddm.packages.${pkgs.system}.default ];
}
