{ config
, pkgs
, inputs
, system
, ...
}:
let
  tresorit-fhs = inputs.nix-tresorit.packages.${system}.default;
  tresorit-launcher = pkgs.writeShellScriptBin "tresorit-fhs-launch" ''
    if [ ! -x "$HOME/.local/share/tresorit/tresorit" ]; then
      printf '%s\n' "Tresorit is not installed. Run tresorit-install first." >&2
      exit 1
    fi

    export QT_QPA_PLATFORM=xcb
    export QT_STYLE_OVERRIDE=
    exec ${tresorit-fhs}/bin/tresorit-fhs -c "$HOME/.local/share/tresorit/tresorit --hidden" \
      >> "$HOME/.local/share/tresorit/fhs.log" 2>&1
  '';
  tresorit-desktop-entry = pkgs.writeText "tresorit-fhs.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=Tresorit
    GenericName=Secure file synchronisation
    Exec=${tresorit-launcher}/bin/tresorit-fhs-launch
    TryExec=${tresorit-launcher}/bin/tresorit-fhs-launch
    Icon=${config.home.homeDirectory}/.local/share/tresorit/tresorit.png
    MimeType=x-scheme-handler/tresorit;
    Categories=Network;FileTransfer;
    StartupNotify=true
  '';
in
{
  home = {
    packages = with pkgs; [
      bitwarden-desktop
      filezilla
      flashprint
      crosspipe
      nautilus
      kdePackages.kdenlive
      glaxnimate
      inkscape
      krita
      losslesscut-bin
      mpv
      openscad
      tresorit-fhs
      tresorit-launcher
      equibop
    ];
  };

  programs.thunderbird = {
    enable = true;
    profiles.drake.isDefault = true;
  };

  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-studio-plugins.obs-advanced-masks ];
  };

  # Shadow OBS's desktop entry to run unscaled — the preview's click
  # hit-testing is offset under 125% fractional scaling, so force OBS
  # (only) to 1x. UI is a bit small; the cursor lines up.
  xdg.desktopEntries."com.obsproject.Studio" = {
    name = "OBS Studio";
    genericName = "Streaming/Recording Software";
    exec = "env QT_QPA_PLATFORM=xcb QT_AUTO_SCREEN_SCALE_FACTOR=0 QT_SCALE_FACTOR=1 obs";
    icon = "com.obsproject.Studio";
    terminal = false;
    categories = [ "AudioVideo" "Recorder" ];
    settings.StartupWMClass = "obs";
  };

  xdg = {
    dataFile."applications/tresorit-fhs.desktop".source = tresorit-desktop-entry;

    configFile = {
      "equibop/settings.json".source = config.lib.meta.createSymlink "home/linux/equibop/settings.json";
      "autostart/tresorit-fhs.desktop".source = tresorit-desktop-entry;

      "mimeapps.list".force = true;
    };

    desktopEntries.discord = {
      name = "Discord";
      genericName = "Internet Messenger";
      exec = "equibop %U";
      icon = "discord";
      categories = [ "Network" "InstantMessaging" "Chat" ];
      type = "Application";
    };

    mimeApps.enable = true;
  };
}
