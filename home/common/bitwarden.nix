{ config
, features
, lib
, pkgs
, ...
}: {
  home = {
    packages = [
      pkgs.rbw
      pkgs.pinentry-curses
    ];

    sessionVariables = lib.mkIf features.gui {
      SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
    };
  };

  xdg.configFile."rbw/config.json".text = builtins.toJSON {
    email = "me@drake.dev";
    pinentry = lib.getExe pkgs.pinentry-curses;
  };
}
