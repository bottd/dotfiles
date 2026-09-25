{ config
, features
, lib
, pkgs
, ...
}:
let
  sshAuthSock = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
in
{
  home = {
    packages = [
      pkgs.rbw
      pkgs.pinentry-curses
    ] ++ lib.optionals features.gui [
      pkgs.bitwarden-desktop
    ];

    sessionVariables = lib.mkIf features.gui {
      SSH_AUTH_SOCK = sshAuthSock;
    };
  };

  # sessionVariables only reach shells
  launchd.agents.bitwarden-ssh-auth-sock = lib.mkIf (features.gui && pkgs.stdenv.isDarwin) {
    enable = true;
    config = {
      ProgramArguments = [ "/bin/launchctl" "setenv" "SSH_AUTH_SOCK" sshAuthSock ];
      RunAtLoad = true;
    };
  };

  xdg.configFile."rbw/config.json".text = builtins.toJSON {
    email = "me@drake.dev";
    pinentry = lib.getExe pkgs.pinentry-curses;
  };
}
