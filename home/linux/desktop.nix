{ config
, pkgs
, inputs
, system
, ...
}:
let
  tresorit-fhs = inputs.nix-tresorit.packages.${system}.default;
in
{
  home = {
    packages = with pkgs; [
      bitwarden-desktop
      filezilla
      flashprint
      crosspipe
      krita
      losslesscut-bin
      mpv
      openscad
      tresorit-fhs
      equibop
    ];

    file.".local/share/tresorit/tresorit_fhs_launcher.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ~/.local/share/tresorit/patch.sh
        printf "Starting Tresorit within FHS environment...\n"
        export QT_QPA_PLATFORM=xcb
        export QT_STYLE_OVERRIDE=
        /etc/profiles/per-user/$USER/bin/tresorit-fhs -c "$HOME/.local/share/tresorit/tresorit --hidden" > "$HOME/.local/share/tresorit/fhs.log" 2>&1 &
        printf "Done.\n"
      '';
    };
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
    configFile = {
      "equibop/settings.json".source = config.lib.meta.createSymlink "home/linux/equibop/settings.json";

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
