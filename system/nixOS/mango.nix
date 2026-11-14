{ lib, pkgs, ... }:
# mango (mangowc), the session greetd starts on mango hosts. niri stays
# installed beside it (system/nixOS/niri), so flipping the host back to
# desktopEnvironment = "niri" is a one-line change.
#
# Not programs.mangowc: its session entry runs bare `mango`, which never starts
# graphical-session.target, so Quickshell, mako and the wallpaper wouldn't come
# up, and nothing would stop the target on exit.
let
  mango = pkgs.mangowc;

  sessionVars = [
    "WAYLAND_DISPLAY"
    "DISPLAY"
    "XDG_CURRENT_DESKTOP"
    "XDG_SESSION_TYPE"
    "XDG_SESSION_DESKTOP"
    "NIXOS_OZONE_WL"
    "XCURSOR_THEME"
    "XCURSOR_SIZE"
  ];

  mangoSession = pkgs.writeShellScriptBin "mango-session" ''
    if systemctl --user -q is-active graphical-session.target; then
      echo "mango-session: a graphical session is already running" >&2
      exit 1
    fi
    systemctl --user reset-failed

    export XDG_CURRENT_DESKTOP=mango XDG_SESSION_DESKTOP=mango XDG_SESSION_TYPE=wayland

    # mango runs -s once its socket (and Xwayland's DISPLAY) exist.
    ${lib.getExe' mango "mango"} -s '${lib.getExe' pkgs.dbus "dbus-update-activation-environment"} --systemd ${lib.concatStringsSep " " sessionVars} && systemctl --user start mango-session.target'

    systemctl --user stop mango-session.target graphical-session.target
    systemctl --user unset-environment ${lib.concatStringsSep " " sessionVars}
  '';

  sessionEntry =
    (pkgs.writeTextDir "share/wayland-sessions/mango.desktop" ''
      [Desktop Entry]
      Name=Mango
      Comment=mango Wayland compositor
      Exec=${lib.getExe mangoSession}
      Type=Application
      DesktopNames=mango;wlroots
    '').overrideAttrs
      { passthru.providedSessions = [ "mango" ]; };
in
{
  environment.systemPackages = [
    mango # mango, mmsg
    mangoSession
    pkgs.grim # screenshots: mango has no built-in one
    pkgs.slurp
    pkgs.wl-clipboard
  ];

  services.displayManager.sessionPackages = [ sessionEntry ];

  # Like niri.service, binds the shared graphical-session.target for its life.
  systemd.user.targets.mango-session = {
    description = "mango compositor session";
    bindsTo = [ "graphical-session.target" ];
    wants = [
      "graphical-session-pre.target"
      # niri-flake hangs its polkit agent off niri.service only.
      "niri-flake-polkit.service"
    ];
    after = [ "graphical-session-pre.target" ];
    before = [ "graphical-session.target" ];
  };

  # Same portal routing nixpkgs' programs.mangowc sets up.
  xdg.portal = {
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
    config.mango = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      "org.freedesktop.impl.portal.ScreenShot" = [ "wlr" ];
      "org.freedesktop.impl.portal.Inhibit" = [ "gtk" ];
    };
  };
}
