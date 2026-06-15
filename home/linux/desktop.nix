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
  home.packages = with pkgs; [
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
  home.sessionVariables = {
    SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
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
