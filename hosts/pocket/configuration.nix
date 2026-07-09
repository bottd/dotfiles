{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../system/common/linux
  ];

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # This panel is mounted sideways. nixos-hardware pins it with a kernel `video=`
  # property that niri honours but the SDDM greeter ignores, so rotate the
  # greeter's X server here. Swap `right` for `left` if it comes up inverted.
  services.displayManager.sddm.setupScript = ''
    ${pkgs.xrandr}/bin/xrandr --output eDP-1 --rotate right
  '';

  # WWAN. ModemManager is already on (networking.networkmanager enables it), but
  # nothing ever declared a connection — a desktop applet would have created one
  # interactively into /etc/NetworkManager/system-connections. We have no applet,
  # so declare it. auto-config pulls the APN from mobile-broadband-provider-info
  # (already in NM's closure) using the SIM's operator id, so no carrier details
  # here. If the SIM has a PIN, add it via ensureProfiles.environmentFiles.
  networking.networkmanager.ensureProfiles.profiles.cellular = {
    connection = {
      id = "cellular";
      type = "gsm";
      autoconnect = true;
    };
    gsm.auto-config = true;
  };

  # grim/slurp/mako now come from the niri modules (screenshots are built-in;
  # mako runs as a home-manager user service).
  environment.systemPackages = with pkgs; [
    crosspipe
    ghostty
  ];
}
