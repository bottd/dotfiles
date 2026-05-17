{ pkgs, username, autologin, ... }:
{
  services = {
    xserver = {
      enable = true;
      windowManager.awesome = {
        enable = true;
        package = pkgs.awesome;
        luaModules = with pkgs.luaPackages; [ luarocks ];
      };

      displayManager.lightdm.enable = true;

      # DP-1 stays primary at native landscape; DP-3 rotates 90° CW (portrait)
      # and sits to the right at x=2560. Mirrors the KDE layout.
      displayManager.sessionCommands = ''
        ${pkgs.xorg.xrandr}/bin/xrandr \
          --output DP-1 --primary --mode 2560x1440 --pos 0x0 --rotate normal \
          --output DP-3 --mode 2560x1440 --pos 2560x0 --rotate right
      '';
    };

    displayManager = {
      defaultSession = "none+awesome";
      autoLogin = {
        enable = autologin;
        user = username;
      };
    };

    # wintc-taskband's tray battery indicator segfaults if UPower's D-Bus name
    # isn't registered. Run upower so it answers — the desktop has no battery
    # to report on, but the daemon's presence is what the taskband needs.
    upower.enable = true;
  };

  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    xclip
    xterm
    rofi
  ];

  fonts.fontconfig.enable = true;
}
