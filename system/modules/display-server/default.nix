# Common display server configuration
{pkgs, ...}: {
  # Basic X11 configuration (used even with Wayland)
  services.xserver = {
    enable = true;

    # Use modern libinput drivers
    libinput = {
      enable = true;
      touchpad = {
        disableWhileTyping = true;
        naturalScrolling = true;
        tapping = true;
        clickMethod = "clickfinger";
      };
    };

    # Default keyboard configuration - can be overridden in host config
    xkb = {
      layout = "us";
      variant = "";
      options = "caps:escape";
    };
  };

  # Hardware acceleration configuration
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  # These are useful for both X11 and Wayland
  environment.systemPackages = with pkgs; [
    xdg-utils
    xorg.xdpyinfo
    xorg.xev
    xorg.xhost
    xorg.xinput
    xorg.xrandr
    mesa
  ];
}
