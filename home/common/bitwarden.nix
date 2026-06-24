{ config
, pkgs
, ...
}: {
  home = {
    packages = [ pkgs.bitwarden-cli ];

    sessionVariables = {
      SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
    };
  };
}
