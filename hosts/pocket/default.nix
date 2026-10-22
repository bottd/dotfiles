{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./optimizations.nix
    ../../system/common/linux
  ];

  # This panel is mounted sideways. nixos-hardware pins it with a kernel `video=`
  # property that niri honours but the SDDM greeter ignores, so rotate the
  # greeter's X server here. Swap `right` for `left` if it comes up inverted.
  services.displayManager.sddm.setupScript = ''
    ${pkgs.xrandr}/bin/xrandr --output eDP-1 --rotate right
  '';

  # WWAN: GPD's optional LTE module is a Quectel EG25-G/EC25 (USB vendor
  # 2c7c). ModemManager is already on (networking.networkmanager enables it).
  #
  # The module ships FCC-locked: ModemManager sees it but it sits in low power
  # and never registers. ModemManager carries Quectel's unlock script but only
  # runs scripts linked into fcc-unlock.d (the Gentoo wiki's Pocket 4 page has
  # the same fix). The NixOS module also puts mbimcli/qmicli on its PATH.
  networking.modemmanager.fccUnlockScripts = [
    {
      id = "2c7c";
      path = "${pkgs.modemmanager}/share/ModemManager/fcc-unlock.available.d/2c7c";
    }
  ];

  # Nothing else declares a connection (an applet would create one
  # interactively), so declare it. auto-config pulls the APN from
  # mobile-broadband-provider-info using the SIM's operator id, so no carrier
  # details here; a carrier missing from that database needs `gsm.apn` set in
  # the connection editor. A SIM PIN is asked for by the bar's network panel.
  # NetworkManager's default route metrics keep Ethernet and Wi-Fi ahead of
  # this, so it only carries traffic when they're down.
  networking.networkmanager.ensureProfiles.profiles.cellular = {
    connection = {
      id = "cellular";
      type = "gsm";
      autoconnect = true;
      # The default of 4 tries gives up for good after a slow registration
      # (waking in a dead zone); 0 keeps retrying.
      autoconnect-retries = 0;
    };
    gsm.auto-config = true;
  };

  services.upower = {
    enable = true;
    criticalPowerAction = "PowerOff";
  };
}
