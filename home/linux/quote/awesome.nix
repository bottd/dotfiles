{ config, lib, pkgs, inputs, ... }:
let
  inherit (config.lib.stylix) colors;
  wintc = inputs.self.packages.${pkgs.system}.xfce-winxp-tc;

  # Procedural Bliss-style wallpaper. The real "Bliss" jpeg (Charles O'Rear,
  # 2001) is copyrighted by Microsoft, so we approximate: sky vertical gradient
  # + a green hill drawn as a quadratic-bezier band, softened with a small
  # blur. Sized to the monitor's native res so wallpaper.maximized doesn't
  # rescale.
  blissPng = pkgs.runCommand "bliss.png"
    {
      nativeBuildInputs = [ pkgs.imagemagick ];
    } ''
    convert -size 2560x1440 gradient:'#3a78c8'-'#a8d4ee' \
      -fill '#5a8d2c' \
      -draw "path 'M -10,960 Q 640,790 1280,910 Q 1920,1030 2570,840 L 2570,1450 L -10,1450 Z'" \
      -fill '#79b03f' \
      -draw "path 'M -10,960 Q 640,790 1280,910 Q 1920,1030 2570,840 L 2570,852 Q 1920,1042 1280,922 Q 640,802 -10,972 Z'" \
      -blur 0x1.6 \
      "$out"
  '';

  # wintc ships the original Luna titlebar button PNGs (21x23, four states each)
  # under its xfwm4 theme. Reuse them instead of redrawing — guarantees pixel
  # parity with the bar/start menu.
  xpButtonDir = ''${wintc}/share/themes/Windows XP style (Blue)/xfwm4'';

  # rc.fnl uses @placeholder@ markers for stylix-driven colors; replaceVars fills them in.
  rcFnl = pkgs.replaceVars ./rc.fnl {
    bgNormal = "#${colors.base00}";
    bgFocus = "#${colors.base0B}";
    bgUrgent = "#${colors.base0C}";
    fgNormal = "#${colors.base05}";
    fgFocus = "#${colors.base00}";
    borderNormal = "#${colors.base02}";
    borderFocus = "#${colors.base0B}";
    blissPath = "${blissPng}";
    inherit xpButtonDir;
  };

  # whitelist awesome's bare globals so fennel still catches typos
  rcLua = pkgs.runCommand "awesome-rc.lua" { } ''
    ${pkgs.luaPackages.fennel}/bin/fennel \
      --globals "client,screen,root,awesome,tag,mouse" \
      --compile ${rcFnl} > $out
  '';

  # OBS icon override; ship 48/128/256 so exact-size lookups don't fall back to upstream
  obsRecordIcons = pkgs.runCommand "obs-record-icons"
    {
      nativeBuildInputs = [ pkgs.imagemagick ];
    } ''
    mkdir -p $out
    convert -size 256x256 xc:transparent \
      -fill '#dcdcdc' -draw 'circle 128,128 128,11' \
      -fill '#1e1e1e' -draw 'circle 128,128 128,33' \
      -fill '#b40f0f' -draw 'circle 128,128 128,58' \
      -fill 'rgba(255,255,255,0.55)' -draw 'ellipse 128,86 48,22 0,360' \
      "$out/256.png"
    for size in 48 128; do
      convert "$out/256.png" -resize "''${size}x''${size}" "$out/$size.png"
    done
  '';
in
{
  xsession = {
    enable = true;
    windowManager.awesome = {
      enable = true;
      package = pkgs.awesome;
    };
    # Pin the monitor mode before awesome starts so screen.geometry and the
    # MC "wallpaper" placement see the native resolution. Hardware-specific
    # to the quote host (single DP-1 panel at 2560x1440 @ 170Hz native).
    initExtra = ''
      ${pkgs.xorg.xrandr}/bin/xrandr --output DP-1 --mode 2560x1440 --rate 170.07 --primary || true
    '';
  };

  # XP cursors are not freely redistributable, so nixpkgs has nothing labelled
  # "Windows XP". Vanilla-DMZ is the closest free family — it's the DMZ theme
  # the Windows-style cursor packs derive from.
  stylix.cursor = {
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
    size = 24;
  };

  xdg = {
    configFile = {
      "awesome/rc.lua".source = rcLua;
    };
    dataFile = {
      "icons/hicolor/48x48/apps/com.obsproject.Studio.png".source =
        "${obsRecordIcons}/48.png";
      "icons/hicolor/128x128/apps/com.obsproject.Studio.png".source =
        "${obsRecordIcons}/128.png";
      "icons/hicolor/256x256/apps/com.obsproject.Studio.png".source =
        "${obsRecordIcons}/256.png";
    };
  };

  home.packages = with pkgs; [
    rofi
    xdotool
    wmctrl
    xorg.xprop
    xorg.xwininfo
    xorg.xset
    xorg.xrandr
    xcape # tap-Super alone → emits Super+Escape, our start-menu toggle
    networkmanagerapplet # nm-applet for the systray
    pasystray # XP-style volume/output icon in the tray, talks to pipewire-pulse
    # corefonts ships Tahoma (and Verdana) under the MS EULA - the actual XP
    # face the taskband and titlebars target.
    corefonts
    wintc
  ];

  # Reload the running awesome in-place after each switch; no-op without DISPLAY.
  home.activation.reloadAwesome = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -n "''${DISPLAY:-}" ]; then
      run ${pkgs.awesome}/bin/awesome-client 'awesome.restart()' >/dev/null 2>&1 || true
    fi
  '';
}
