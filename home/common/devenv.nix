{ pkgs, ... }: {
  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
      silent = true;
    };
  };

  home.packages = with pkgs; [
    devenv
  ];
  nix.settings.trusted-users = [ "root" "drakeb" ];
}
