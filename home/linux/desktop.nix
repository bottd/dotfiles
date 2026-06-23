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
      bitwarden-cli
      bitwarden-desktop
      filezilla
      flashprint
      crosspipe
      krita
      losslesscut-bin
      mpv
      obs-studio
      openscad
      tresorit-fhs
      equibop
    ];

    # Use Bitwarden's built-in SSH agent. The agent itself is toggled on in the
    # desktop app: Settings -> enable "SSH agent" (must be running + unlocked).
    sessionVariables = {
      SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
    };

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
