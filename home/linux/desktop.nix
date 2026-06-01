{ config
, pkgs
, inputs
, system
, ...
}:
let
  tresorit-fhs = inputs.nix-tresorit.packages.${system}.default;
  tresorit-launcher = pkgs.writeShellScriptBin "tresorit" ''
    export QT_QPA_PLATFORM=xcb
    export QT_STYLE_OVERRIDE=
    exec ${tresorit-fhs}/bin/tresorit-fhs -c '$HOME/.local/share/tresorit/tresorit '"$*"
  '';
in
{
  home.packages = with pkgs; [
    filezilla
    flashprint
    crosspipe
    krita
    losslesscut-bin
    mpv
    obs-studio
    openscad
    tresorit-fhs
    tresorit-launcher
    equibop
  ];

  programs.thunderbird = {
    enable = true;
    profiles.drake.isDefault = true;
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

    desktopEntries.tresorit = {
      name = "Tresorit";
      genericName = "Secure File Sync";
      comment = "Secure file synchronization and sharing";
      exec = "tresorit --hidden";
      icon = "${config.home.homeDirectory}/.local/share/tresorit/tresorit.png";
      categories = [ "Network" "FileTransfer" "Utility" ];
      type = "Application";
      mimeType = [ "x-scheme-handler/tresorit" ];
    };

    mimeApps.enable = true;
  };
}
